From: Steve Dickson <SteveD@redhat.com>
Subject: Re: how to interpret 'nfsstat' ouput
Date: Thu, 18 Sep 2003 09:53:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F69B8D0.3090105@RedHat.com>
References: <20030918061313.58617.qmail@web13108.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zzDf-0005lB-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 06:53:15 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zzDe-0003Ag-54
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 06:53:14 -0700
To: sreya <m_sreya@yahoo.com>
In-Reply-To: <20030918061313.58617.qmail@web13108.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



sreya wrote:

>hi,
>Iam trying to trace NFS output to determine the health
>of NFS. CAn anyone please tell me how to interpret the
>NFS statistics and decide the condition of NFS i.e,
>whether the NFS server is not working or NFS is about
>to die etc.
>I want to know the statistics on the server side
>without any intervention of the clients present.
>
what's wrong with doing a nfsstat -s (on the server) and
the noting the rpc calls count?

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
