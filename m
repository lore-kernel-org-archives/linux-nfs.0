From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 12:11:58 -0500 (EST)
Message-ID: <200801041711.MAA19577@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: jeff@garzik.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

> heh, tell me about it.  First I started out using rpcgen, then rewrote 
> everything to do raw XDR decoding.  OPEN is huge.
> 
> IMO, OPEN should be split into multiple operations, probably one for 
> each "OPEN arm".  It's not like new opcode numbers are expensive.

As I hinted at, Open is the way it is, since Windows requires one Op
so that Open/Share locks can be implemented correctly. Anything else
would not have satisfied a Win client's requirements.

> One of my personal desires is for a high level of cache coherence 
> throughout the system for all clients (though perhaps an admin could 
> optionally relax this requirement).  I'm a fan of Google's "Chubby", a 
> distributed reliable filesystem that stalls client writes until cache 
> invalidations for the associated byte range are processed for all 
> interested clients.

Delegations provide cache coherency "in a sense". When a client has a
delegation, it knows that no-one else is writing the file. Unfortunately,
as soon as a client gets an Open without a delegation, in no longer
gets the conherency guarantee (and servers are completely free to not
issue delegations if they don't feel like doing so). A client can
re-open a file when it gets an Open without a delegation, but if the
server still doesn't give it a delegation, it can't do anything more.
(The re-open trick is useful for an Open that requires confirmation, since
 the server can't issue a delegation for that case.)

rick
