From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 16:36:34 +0100
Message-ID: <20090212153634.GB28107@janus>
References: <20090211112318.GA29133@janus> <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus> <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus> <1234451789.7190.38.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:43838 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750703AbZBLPgh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 10:36:37 -0500
In-Reply-To: <1234451789.7190.38.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2009 at 10:16:29AM -0500, Trond Myklebust wrote:
> On Thu, 2009-02-12 at 15:28 +0100, Frank van Maarseveen wrote:
> > On Wed, Feb 11, 2009 at 03:39:48PM -0500, J. Bruce Fields wrote:
> > > On Wed, Feb 11, 2009 at 09:37:03PM +0100, Frank van Maarseveen wrote:
> > > > On Wed, Feb 11, 2009 at 03:35:55PM -0500, J. Bruce Fields wrote:
> > > > > On Wed, Feb 11, 2009 at 12:23:18PM +0100, Frank van Maarseveen wrote:
> > > > > > I'm sorry to inform you but... it seems that there is a similar problem
> > > > > > in the NLM subsystem as reported previously but this time it is triggered
> > > > > > when the grace time expires after a reboot.
> > > > > > 
> > > > > > Client and server run 2.6.27.14 + previous fix, NFSv3.
> > > > > > 
> > > > > > On the client there are three shells running:
> > > > > > 
> > > > > > 	while :; do lck -w /mnt/foo 2; done
> > > > > > 
> > > > > > The "lck" program is the same as posted before and it obtains an exclusive
> > > > > > write lock then waits 2 seconds in above invocation (there's probably an
> > > > > > "fcntl" command equivalent). After an orderly server reboot + grace time
> > > > > 
> > > > > How are you rebooting the server?
> > > > 
> > > > "reboot"
> > > 
> > > Could you watch the nfs/nlm/nsm traffic on reboot and make sure that the
> > > server is actually sending the reboot notification to the client, and
> > > that the client is trying to reclaim?  (Wireshark should make this all
> > > fairly clear.  But capture the traffic with tcpdump -s0 -wtmp.pcap and
> > > send it to me if you're having trouble interpreting it.)
> > 
> > I have a capture with comment below. It raised so many questions
> > that I decided to do some more testing, trying to figure out how
> > it looks when the locking works. This issue now appears to predate the
> > fuse changes and is also present when both client and server run
> > 2.6.24.4. I decided to stick with the traffic capture for 2.7.27.14 +
> > previous fix as discussed earlier. The full capture is available at
> > http://www.frankvm.com/tmp/2.6.27.14-nlm-grace.pcap. It's about 33k and
> > was started on the server as part of initscripts, right after the reboot
> > and filtered on client IP address.
> > 
> > Exported by wireshark (filter: nfs or stat or nlm) and condensed:
> > 
> >   #   time      src      prot
> >   1   0.000000  client:  NFS  V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >   2   0.000018  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >   5   0.000583  server:  ICMP Destination unreachable (Port unreachable)
> >   6   0.000589  server:  ICMP Destination unreachable (Port unreachable)
> >   7   1.891277  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >   8   1.891320  server:  ICMP Destination unreachable (Port unreachable)
> >   9   5.827053  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  10   5.827119  server:  ICMP Destination unreachable (Port unreachable)
> >  11  14.626501  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  12  14.626587  server:  ICMP Destination unreachable (Port unreachable)
> >  15  15.726426  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  16  15.726505  server:  ICMP Destination unreachable (Port unreachable)
> >  17  17.926284  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  18  17.926368  server:  ICMP Destination unreachable (Port unreachable)
> >  25  22.326006  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  26  22.326090  server:  ICMP Destination unreachable (Port unreachable)
> >  35  30.022271  client:  NLM  V4 UNLOCK Call (Reply In 36) FH:0xcafa61cc svid:114 pos:0-0
> >  36  30.029511  server:  NLM  V4 UNLOCK Reply (Call In 35) NLM_DENIED_GRACE_PERIOD
> >  37  30.029660  client:  NLM  V4 LOCK Call (Reply In 39) FH:0xcafa61cc svid:116 pos:0-0
> >  38  30.029691  client:  NLM  V4 LOCK Call (Reply In 40) FH:0xcafa61cc svid:115 pos:0-0
> >  39  30.029884  server:  NLM  V4 LOCK Reply (Call In 37) NLM_DENIED_GRACE_PERIOD
> >  40  30.029914  server:  NLM  V4 LOCK Reply (Call In 38) NLM_DENIED_GRACE_PERIOD
> >  41  31.125403  client:  NFS  [RPC retransmission of #1]V3 GETATTR Call (Reply In 42), FH:0x0308030a
> >  42  31.127499  server:  NFS  V3 GETATTR Reply (Call In 1)  Directory mode:0755 uid:0 gid:0
> >  43  31.127942  client:  NFS  V3 GETATTR Call (Reply In 45), FH:0x0308030a
> >  45  31.129378  server:  NFS  V3 GETATTR Reply (Call In 43)  Directory mode:0755 uid:0 gid:0
> >  47  31.129958  server:  STAT V1 NOTIFY Call (Reply In 48)
> >  48  31.130301  client:  STAT V1 NOTIFY Reply (Call In 47)
> > 
> > Reboot notification ok.
> > 
> >  51  35.029968  client:  NLM  V4 UNLOCK Call (Reply In 54) FH:0xcafa61cc svid:114 pos:0-0
> >  52  35.030003  client:  NLM  V4 LOCK Call (Reply In 55) FH:0xcafa61cc svid:116 pos:0-0
> >  53  35.030016  client:  NLM  V4 LOCK Call (Reply In 56) FH:0xcafa61cc svid:115 pos:0-0
> >  54  35.030085  server:  NLM  V4 UNLOCK Reply (Call In 51) NLM_DENIED_GRACE_PERIOD
> >  55  35.030126  server:  NLM  V4 LOCK Reply (Call In 52) NLM_DENIED_GRACE_PERIOD
> >  56  35.030153  server:  NLM  V4 LOCK Reply (Call In 53) NLM_DENIED_GRACE_PERIOD
> > 
> > The three contending client processes. I don't see a lock registration for
> > svid:114, only UNLOCK calls which fail with NLM_DENIED_GRACE_PERIOD. The
> > above goes on for a while. Neither the server or client shows any lock
> > in /proc/locks at this point.
> > 
> > 166 115.028376  client:  NLM  V4 LOCK Call (Reply In 168) FH:0xcafa61cc svid:115 pos:0-0
> > 167 115.028394  client:  NLM  V4 LOCK Call (Reply In 169) FH:0xcafa61cc svid:116 pos:0-0
> > 168 115.028440  server:  NLM  V4 LOCK Reply (Call In 166) NLM_DENIED_GRACE_PERIOD
> > 169 115.028465  server:  NLM  V4 LOCK Reply (Call In 167) NLM_DENIED_GRACE_PERIOD
> > 170 120.027233  client:  NLM  V4 UNLOCK Call (Reply In 171) FH:0xcafa61cc svid:114 pos:0-0
> > 171 120.027337  server:  NLM  V4 UNLOCK Reply (Call In 170) NLM_DENIED_GRACE_PERIOD
> > 172 120.028234  client:  NLM  V4 LOCK Call (Reply In 175) FH:0xcafa61cc svid:116 pos:0-0
> > 173 120.028258  client:  NLM  V4 LOCK Call (Reply In 174) FH:0xcafa61cc svid:115 pos:0-0
> > 174 120.030601  server:  NLM  V4 LOCK Reply (Call In 173)
> > 175 120.030656  server:  NLM  V4 LOCK Reply (Call In 172) NLM_BLOCKED
> > 
> > This doesn't add up. There hasn't been a successful unlock for svid:114
> > (see #213 for that) but still one of the locks is granted.
> 
> Has the lock for svid:114 been attempted recovered by the client? If
> not, then the server has no knowledge of that lock.

exactly. Apparently the client tries to unlock an unrecovered lock.

> 
> > 176 120.030781  client:  NLM  V4 LOCK Call (Reply In 177) FH:0xcafa61cc svid:115 pos:0-0
> > 177 120.030849  server:  NLM  V4 LOCK Reply (Call In 176)
> > 
> > Strange: an identical lock request but with a different rpc xid (i.e. no
> > packet duplication).
> 
> No. That would be the non-blocking lock that is intended as a 'ping' to
> see if the server is still alive. It duplicates the blocking lock in all
> details except that the 'block' flag is not set.
> 
> > 178 120.031078  client:  NFS  V3 GETATTR Call (Reply In 179), FH:0xcafa61cc
> > 179 120.031154  server:  NFS  V3 GETATTR Reply (Call In 178)  Regular File mode:0644 uid:363 gid:1500
> > 180 120.033973  client:  NFS  V3 ACCESS Call (Reply In 181), FH:0x0308030a
> > 181 120.034030  server:  NFS  V3 ACCESS Reply (Call In 180)
> > 182 120.034223  client:  NFS  V3 LOOKUP Call (Reply In 183), DH:0x0308030a/loc
> > 183 120.034285  server:  NFS  V3 LOOKUP Reply (Call In 182), FH:0x81685ca0
> > 184 120.034472  client:  NFS  V3 ACCESS Call (Reply In 185), FH:0x0308030c
> > 185 120.034526  server:  NFS  V3 ACCESS Reply (Call In 184)
> > 186 120.034722  client:  NFS  V3 ACCESS Call (Reply In 187), FH:0x0308030c
> > 187 120.034776  server:  NFS  V3 ACCESS Reply (Call In 186)
> > 188 120.034922  client:  NFS  V3 LOOKUP Call (Reply In 189), DH:0x0308030c/locktest
> > 189 120.034993  server:  NFS  V3 LOOKUP Reply (Call In 188), FH:0xcafa61cc
> > 190 120.035172  client:  NFS  V3 ACCESS Call (Reply In 191), FH:0xcafa61cc
> > 191 120.035230  server:  NFS  V3 ACCESS Reply (Call In 190)
> > 193 122.032218  client:  NLM  V4 UNLOCK Call (Reply In 195) FH:0xcafa61cc svid:115 pos:0-0
> > 194 122.032253  client:  NLM  V4 LOCK Call (Reply In 197) FH:0xcafa61cc svid:119 pos:0-0
> > 195 122.032343  server:  NLM  V4 UNLOCK Reply (Call In 193)
> > 197 122.032794  server:  NLM  V4 LOCK Reply (Call In 194) NLM_BLOCKED
> > 201 122.033767  server:  NLM  V4 GRANTED_MSG Call (Reply In 202) FH:0xcafa61cc svid:116 pos:0-0
> > 202 122.034066  client:  NLM  V4 GRANTED_MSG Reply (Call In 201)
> > 205 122.034665  client:  NLM  V4 GRANTED_RES Call (Reply In 206) NLM_DENIED
> > 206 122.034753  server:  NLM  V4 GRANTED_RES Reply (Call In 205)
> 
> What happened here? Why did the client refuse the lock for svid 116?
> 
> Did the task get signalled? If so, where is the CANCEL request?

The task did not get signaled, there is no CANCEL.

> 
> > 207 122.036312  client:  NFS  V3 GETATTR Call (Reply In 208), FH:0xcafa61cc
> > 208 122.036394  server:  NFS  V3 GETATTR Reply (Call In 207)  Regular File mode:0644 uid:363 gid:1500
> > 209 122.036611  client:  NLM  V4 LOCK Call (Reply In 210) FH:0xcafa61cc svid:120 pos:0-0
> > 210 122.036674  server:  NLM  V4 LOCK Reply (Call In 209) NLM_BLOCKED
> > 213 125.027091  client:  NLM  V4 UNLOCK Call (Reply In 214) FH:0xcafa61cc svid:114 pos:0-0
> > 214 125.027194  server:  NLM  V4 UNLOCK Reply (Call In 213)
> > 215 125.029487  client:  NFS  V3 GETATTR Call (Reply In 216), FH:0xcafa61cc
> > 216 125.029570  server:  NFS  V3 GETATTR Reply (Call In 215)  Regular File mode:0644 uid:363 gid:1500
> > 217 125.029836  client:  NLM  V4 LOCK Call (Reply In 218) FH:0xcafa61cc svid:121 pos:0-0
> > 218 125.029895  server:  NLM  V4 LOCK Reply (Call In 217) NLM_BLOCKED
> > 224 152.032157  client:  NLM  V4 LOCK Call (Reply In 225) FH:0xcafa61cc svid:119 pos:0-0
> > 225 152.032283  server:  NLM  V4 LOCK Reply (Call In 224) NLM_BLOCKED
> > 226 152.035103  client:  NLM  V4 LOCK Call (Reply In 227) FH:0xcafa61cc svid:120 pos:0-0
> > 227 152.035157  server:  NLM  V4 LOCK Reply (Call In 226) NLM_BLOCKED
> > 230 155.029676  client:  NLM  V4 LOCK Call (Reply In 231) FH:0xcafa61cc svid:121 pos:0-0
> > 231 155.029761  server:  NLM  V4 LOCK Reply (Call In 230) NLM_BLOCKED
> > 
> > To recap the problem: one of the fcntl calls to obtain a write lock
> > returns
> > 
> > 	lck: fcntl: No locks available
> > 
> > shortly after the grace period expires. After that everything gets stuck,
> > server holding a write lock with no corresponding client side lock.
> > 
> > 
> > IMO looks like the client is to blame, even if/when the server
> > should/could have accepted UNLOCK during grace (I don't know, I'm not
> > an expert on that one).
> 
> Possibly... It depends entirely on what happened to cause it to deny the
> GRANTED callback...

A little theorizing:
If the unlock of a yet unrecovered lock has failed up to that point then
the client sure must remember the lock somehow. That might explain the
secondary error when a conflicting lock is granted by the server.

-- 
Frank
