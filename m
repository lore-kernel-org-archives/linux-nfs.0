From: Simon Kirby <sim@netnation.com>
Subject: [knfsd] Unable to read in knfsd-exported on ext3 chattr +a'd directories
Date: Mon, 27 Jan 2003 13:57:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030127215718.GA3241@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

'Lo,

I'm unable to read an NFS-mounted directory which is exported from a box
running 2.4.20 and where the directory is chattr'd +a (append only) on an
ext3 filesystem.  Is knfsd attempting to create temporary files in the
directory or is there some other reason why this is failing?

strace snippet of "ls -al ." on client:

open(".", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|S_ISVTX|0733, st_size=98304, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
brk(0x805a000)                          = 0x805a000
getdents64(0x3, 0x8056808, 0x2000, 0)   = -1 EPERM (Operation not
permitted)
getdents(3, 0xbfffe294, 5960)           = -1 EPERM (Operation not
permitted)
close(3)                                = 0

Thanks,

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][     NetNation Communications     ]
[  Opinions expressed are not necessarily those of my employer. ]


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
