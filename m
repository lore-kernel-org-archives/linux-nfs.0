From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 002 of 2] Avoid
 flush-when-locking	when	interclient consistency not needed.
Date: Mon, 16 Apr 2007 10:48:31 -0400
Message-ID: <46238CBF.4090700@redhat.com>
References: <20070306163710.8128.patches@notabene>	
	<1070306054029.8360@suse.de>	
	<1173192029.6393.52.camel@heimdal.trondhjem.org>	
	<17903.17597.832563.922428@notabene.brown>	
	<1176589265.6089.20.camel@heimdal.trondhjem.org>	
	<4622D614.5030500@oracle.com>
	<1176734503.6761.37.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdSXO-0007jH-LF
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:50:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdSVd-0001Uk-Ix
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 07:48:49 -0700
In-Reply-To: <1176734503.6761.37.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
>
>
> On Mon, 16 Apr 2007 at 10:12:09 -0400, Peter Staubach wrote:
>   
>> "llock" or "local lock" implies that only local locks will be used.
>> Thus, only the locks that the kernel is managing are used or kept
>> track of.  No over the wire traffic for locking is issued.
>>
>> With this option, caching is enabled.
>>     
>
> So are you saying that 'llock' basically mirrors our 'nolock', or does
> it additionally disable the flushing operations? If the latter, then I
> suggest that we add a mount flag, NFS_MOUNT_LLOCK which automatically
> sets NFS_MOUNT_NONLM + a new flag that just disables the cache flush on
> lock/unlock.

I believe that the use of "llock" also disables the cache flush at
lock/unlock.  Perhaps someone with access to the OpenSolaris code,
who isn't worried about CDDL versus GPL issues, could look to verify.
It has been a bit since I've worked on that code.

I do remember that the "llock" code was designed to be used for things
like root file systems, where there shouldn't be any conflicts between
different clients, and hence, no need for special page cache handling.

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
