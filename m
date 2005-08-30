From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rquota overflow fix never applied ?
Date: Tue, 30 Aug 2005 16:09:29 +1000
Message-ID: <17171.63513.738531.932794@cse.unsw.edu.au>
References: <200508300108.52636.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E9zJU-0002Ix-GD
	for nfs@lists.sourceforge.net; Mon, 29 Aug 2005 23:09:40 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E9zJS-0003Tp-1q
	for nfs@lists.sourceforge.net; Mon, 29 Aug 2005 23:09:40 -0700
To: Mike Frysinger <vapier@gentoo.org>
In-Reply-To: message from Mike Frysinger on Tuesday August 30
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

On Tuesday August 30, vapier@gentoo.org wrote:
> Gentoo and Fedora both apply an old patch to resolve an overflow issue ... is 
> this just a case of fixes never going upstream or is there a reason this 
> hasnt been applied ... if so, can someone please clue me in ;)
> -mike

Well..... the patch does seem to be somewhat flawed .....
There is a comment, and matching code, and the code is changed, but
not the comment !!! :-)

However I don't think that would be the reason.  I think it either has
not been sent upstream, it when it was it was missed and not resent.

I have added it to my tree, with appropriate changes to the comment.

However I seem to be a bit thick today and cannot see where the
overflow is happening.
dqblk is 6 u_int32_t's and 2 time_t's
struct rquota (after rq_bhardlimit) is 8 u_int's

On what arch are there different?
(maybe time_t isn't 32bits everwhere, is that it?)

NeilBrown

> @@ -168,8 +169,16 @@ getquota_rslt *getquotainfo(int flags, c
>            * Make a copy of the info into the last part of the remote quota
>            * struct which is exactly the same.
>            */


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
