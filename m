From: Paul Jakma <paul@clubi.ie>
Subject: Re: NFS/2.4.18/reiserfs question
Date: Wed, 11 Sep 2002 08:54:38 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209110853090.29369-100000@fogarty.jakma.org>
References: <Pine.LNX.4.44L1.0209101624160.6472-100000@sequence.stanford.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS at SourceForge <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Troy Wu <troy@sequence.stanford.edu>
In-Reply-To: <Pine.LNX.4.44L1.0209101624160.6472-100000@sequence.stanford.edu>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 10 Sep 2002, Troy Wu wrote:

> I've been doing some reading on ReiserFS and know that it has trouble with
> NFS in certain situations.  I'd like to know if my problem is NFS-related
> or ReiserFS-related.

it's to do with how reiserfs assigns inode numbers.

> determine if I'm in that situation, and possibly help me to decide
> (if ReiserFS is the problem) if XFS will help?

Well, the tried and tested solution would be to use ext3.

> Thanks,
> 
> 	--troy

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
It's not whether you win or lose but how you played the game.
		-- Grantland Rice



-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
