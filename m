From: Peter Staubach <staubach@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server
 when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 08:36:09 -0500
Message-ID: <43FDBA49.1000802@redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCGdp-0001O6-Rp
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:36:21 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCGdp-0002Ey-KN
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 05:36:21 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id k1NDaAAt027977
	for <nfs@lists.sourceforge.net>; Thu, 23 Feb 2006 08:36:10 -0500
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil Horman wrote:

>Hey all-
>	I've got a dillema and I'm not sure how to anwser it.  I recently had
>someone mention to me that some of the operations executed via fcntl
>(specifically F_SETLEASE was demonstrated to me) don't check the file attributes
>on the server before executing their operations.  This can lead to erroneous
>behavior in which, if someone updates file permissions or ownership from another
>node mounting an NFS share, a node attempting to do something like a F_SETLEASE
>operation will fail when it should succede, or vice versa.
>
>	I can see who this could be interpreted as a bug, but I can also see how
>we might not want to change the behavior, given that the fcntl code currently
>does not call down to the underlying filesystem for most operations (as it
>doesn't nominally need to), and the problem can easily be avoided by the use of
>a file lock and a stat operation.  Is there consensus on this issue, as to how
>it should operate, or how we would like it to operate?
>

It seems to me that all operations, which use attributes, in any fashion,
whether to make decisions or to return them to the user level, should
verify that the attributes are up to date before using them.  This 
verification
may mean talking to the server or simply deciding that the attributes are
up to date because they are still within the attribute cache timeout period.
The "noac" option should mean, perhaps among other things, that the 
attribute
cache timeout period is zero in length.

If the fcntl code doesn't call into the file system to do the actual
operations, then it needs to verify that the attributes that it is using
are up to date.  If it doesn't, then it is broken and needs to be modified
to do so.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
