From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: TCP write queue full message..
Date: 28 Jan 2003 13:52:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsof61xwqb.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0301280600080.2079-100000@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Dave Airlie <airlied@linux.ie>
In-Reply-To: <Pine.LNX.4.44.0301280600080.2079-100000@skynet>
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

>>>>> " " == Dave Airlie <airlied@linux.ie> writes:

     > Now I'm running over UDP so I cannot understand where the TCP
     > write queue full is coming from, (is the message just
     > in-correct or should I never see it with UDP?? ).. the packet
     > goes out on the wire over UDP and ethereal sees the corrupt RPC
     > request...

Yeah, that's a bit of a historical misnomer: it is no longer a
TCP-specific write queue.

The above message just means that the socket is congested due to too
many outstanding requests, and that your request is therefore being
delayed until the congestion clears up.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
