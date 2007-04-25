From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Wed, 25 Apr 2007 11:44:41 -0400
Message-ID: <462F7769.4080304@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>	<462E6812.6040401@RedHat.com>
	<462E6A54.1010709@redhat.com> <200704251356.35926.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgjfo-0006iF-RS
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 08:44:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hgjfq-0005bC-8c
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 08:44:55 -0700
In-Reply-To: <200704251356.35926.okir@lst.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Olaf Kirch wrote:
> On Tuesday 24 April 2007 22:36, Peter Staubach wrote:
>   
>> I don't think that I understand why being bug for bug compatible with
>> the current glibc code is interesting.  This is a new version of the
>>     
>
> Well, you don't want to re-introduce bugs that have been fixed in
> glibc ages ago, right? Especially when it comes to security issues
> and thread safety.

No, clearly, I wouldn't want to do that.  However, I don't believe that
that is what is meant by "bug for bug compatible".

It is also a distinct possibility that the folks maintaining the TI-RPC
code which is in common use may have fixed a few bugs since the Linux
source bases, either the glibc or tirpc versions, were acquired.  I
think that it would be good to have those, _plus_ any bugs which may
already been fixed in the glibc version.  Wouldn't you agree?

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
