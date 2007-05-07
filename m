From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RFC - remove rquotad from nfs-utils for 1.1.0.
Date: Mon, 07 May 2007 08:08:07 -0400
Message-ID: <463F16A7.8070703@RedHat.com>
References: <17982.32811.860687.644860@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hl1zr-0006Qr-N8
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 05:07:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hl1zu-0003r8-5y
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 05:07:22 -0700
In-Reply-To: <17982.32811.860687.644860@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



Neil Brown wrote:
> It appears that both "nfs-utils" and "quota" have an implementation of
> rquotad.
> 
> This is not a good thing as inevitably one will get maintained and the
> other not.
> 
> It appears that the one in nfs-utils is not being maintained.  A quick
> look shows that it ignores anything other than ext2 or ext3.  This
> suggests that no one has seriously used it for quite a long time.
> 
> I am in favour of removing it from nfs-utils for 1.1.0.  I note that
> neither SuSE or Debian use it (they both use the version from the
> quota package) I suspect other distros do that same.
In RHEL and FC, we also use the rpc.rquotad from the quota package
although the nfs-utils initscript still starts the daemon which
may or may not be a good idea... But I see no harm in removing it..

> 
> Can I get someone to second my nomination?
I seconded it!

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
