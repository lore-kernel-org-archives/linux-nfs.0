From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: NFS as a Cluster File System.
Date: Thu, 9 Jan 2003 22:50:19 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030109215019.GN2437@marowsky-bree.de>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gate.in-addr.de ([212.8.193.158] helo=mx.in-addr.de)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WkZp-0000gm-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 13:51:01 -0800
To: Lorn Kay <lorn_kay@hotmail.com>, nfs@lists.sourceforge.net,
	linux-ha@muc.de
In-Reply-To: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
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

On 2003-01-09T19:39:50,
   Lorn Kay <lorn_kay@hotmail.com> said:

> Is NFS a viable CFS? (I'm cross posting this due to a discussion on the the 
> linux-ha list recently.)

NFS might be a viable system for making content available in a cluster, given
a highly available NFS sever (not that easy to do right, actually) and
provided that the bandwidth and latency is good enough for you; file locking
might also be a problem.

However, it is NOT a "CFS", which people commonly use to refer to a filesystem
which is distributed and usually shares the same storage system connected to
all nodes.

I believe there might be a confusion of words here ;-)


Sincerely,
    Lars Marowsky-Brée <lmb@suse.de>

-- 
Principal Squirrel 
SuSE Labs - Research & Development, SuSE Linux AG
  
"If anything can go wrong, it will." "Chance favors the prepared (mind)."
  -- Capt. Edward A. Murphy            -- Louis Pasteur


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
