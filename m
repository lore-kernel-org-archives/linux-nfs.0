From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: [OT] (autofs) Re: Direct mounts on Linux
Date: Tue, 21 Jan 2003 02:23:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030121072351.GC12523@questra.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com> <20030120214134.GE1042@questra.com> <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com> <20030121030851.GG10369@questra.com> <p5wukzyx8m.fsf@lemming.engeast.baynetworks.com> <20030121040318.GI10369@questra.com> <p5r8b7yr4l.fsf@lemming.engeast.baynetworks.com> <20030121064851.GK10369@questra.com> <p5iswjyocn.fsf@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
In-Reply-To: <p5iswjyocn.fsf@lemming.engeast.baynetworks.com>
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

Paul Smith on Tue 21/01 02:05 -0500:
> No, I mean getcwd(3), the C runtime library function... if my program
> invokes this then it doesn't matter what the shell does.

Not if you chdir("/") like a good little daemon

yeah I know, I get your point :) If that is the only argument against
direct mounts though, I really don't understand statements like
"[Autofs.  Will.  Never.  Support.  Direct.  Maps.  Period.  Full Stop.]"

(see autofs mailing list archives from H. Peter Anvin)


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
