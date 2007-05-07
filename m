From: Jeff Layton <jlayton@redhat.com>
Subject: Re: RFC - remove rquotad from nfs-utils for 1.1.0.
Date: Mon, 7 May 2007 07:58:55 -0400
Message-ID: <20070507115855.GB26568@salusa.poochiereds.net>
References: <17982.32811.860687.644860@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hl1rk-00060n-Rb
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 04:58:57 -0700
Received: from ms-smtp-03.southeast.rr.com ([24.25.9.102])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hl1rm-0001N2-Af
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 04:58:59 -0700
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

On Mon, May 07, 2007 at 11:26:03AM +1000, Neil Brown wrote:
> 
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
> 
> Can I get someone to second my nomination?
> 
> Thanks,
> 
> NeilBrown
> 

Sounds reasonable to me. Fedora also ships the one in the "quota" package,
fwiw...

-- Jeff

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
