From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: [NFS] making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 14:24:25 -0400
Message-ID: <1121711065.23863.31.camel@barsoom.rdu.redhat.com>
References: <1121614708.6713.41.camel@localhost.localdomain>
	<1121700961.8780.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121700961.8780.13.camel@lade.trondhjem.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://hera.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2005-07-18 at 11:36 -0400, Trond Myklebust wrote:
> There's nothing preventing it from working, but what is stopping you
> from developing a fully automatic version?

Nothing is stopping that, but if we're going to do so much in the mount
program, there's probably no point in doing all of this in autofs. Why
do RPC pings at all in autofs if we're going to turn right around and do
them again in the mount program? For mounting over a WAN (for instance)
the ping checks could really add up to a substantial delay in mounting.

For now, I'd like to keep my initial patch somewhat small and simple and
simply make the addr= option be respected, but I'd certainly consider
redoing it to add the stuff you mention above at a later time.

My suggestion would be to consider this in conjunction with autofs v5
(or a later v4 version) so we don't end up duplicating so much
functionality.

-- 
Jeff Layton <jtlayton@poochiereds.net>
