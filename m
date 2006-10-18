From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS inconsistent behaviour
Date: Wed, 18 Oct 2006 13:57:09 -0400
Message-ID: <1161194229.6095.81.camel@lade.trondhjem.org>
References: <A93BD15112CD05479B1CD204F7F1D4730513DB@exch-04.noida.hcltech.com>
	 <46465bb30610160013v47524589g39c61465b5955f65@mail.gmail.com>
	 <20061016084656.GA13292@janus>
	 <46465bb30610160235m211910b6g2eb074aa23060aa9@mail.gmail.com>
	 <20061016093904.GA13866@janus>
	 <46465bb30610171822h3f747069ge9a170f1759af645@mail.gmail.com>
	 <20061018063945.GA5917@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mohit Katiyar <katiyar.mohit@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422716AbWJRR52@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20061018063945.GA5917@janus>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-10-18 at 08:39 +0200, Frank van Maarseveen wrote:
> On Wed, Oct 18, 2006 at 10:22:44AM +0900, Mohit Katiyar wrote:
> > I checked it today and when i issued the netstat -t ,I could see a lot
> > of tcp connections in TIME_WAIT state.
> > Is this a normal behaviour?
> 
> yes... but see below
> 
> > So we cannot mount and umount infinitely
> > with tcp option? Why there are so many connections in waiting state?
> 
> I think it's called the 2MSL wait: there may be TCP segments on the
> wire which (in theory) could disrupt new connections which reuse local
> and remote port so the ports stay in use for a few minutes. This is
> standard TCP behavior but only occurs when connections are improperly
> shutdown. Apparently this happens when umounting a tcp NFS mount but
> also for a lot of other tcp based RPC (showmount, rpcinfo).  I'm not
> sure who's to blame but it might be the rpc functions inside glibc.
> 
> I'd switch to NFS over udp if this is problem.

Just out of interest. Why does anyone actually _want_ to keep
mount/umounting to the point where they run out of ports? That is going
to kill performance in all sorts of unhealthy ways, not least by
completely screwing over any caching.

Note also that you _can_ change the range of ports used by the NFS
client itself at least. Just edit /proc/sys/sunrpc/{min,max}_resvport.
On the server side, you can use the 'insecure' option in order to allow
mounts that originate from non-privileged ports (i.e. port > 1024).
If you are using strong authentication (for instance RPCSEC_GSS/krb5)
then that actually makes a lot of sense, since the only reason for the
privileged port requirement was to disallow unprivileged NFS clients.

Cheers,
  Trond
