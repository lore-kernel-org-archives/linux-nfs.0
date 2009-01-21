From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 21:06:40 -0200
Message-ID: <20090121230640.GD5184@ghostprotocols.net>
References: <4970B451.4080201@RedHat.com> <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> <497757D1.7090908@RedHat.com> <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com> <49777988.6010401@RedHat.com> <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com> <4977A385.8000406@melbourne.sgi.com> <20090121224740.GC5184@ghostprotocols.net> <1232578666.7692.98.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,         Greg Banks <gnb@melbourne.sgi.com>,         Linux NFS Mailing list <linux-nfs@vger.kernel.org>,         Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,         SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <systemtap-return-10981-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <1232578666.7692.98.camel@heimdal.trondhjem.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>

Em Wed, Jan 21, 2009 at 05:57:46PM -0500, Trond Myklebust escreveu:
> On Wed, 2009-01-21 at 20:47 -0200, Arnaldo Carvalho de Melo wrote:
> > Em Thu, Jan 22, 2009 at 09:36:53AM +1100, Greg Banks escreveu:
> > > Chuck Lever wrote:
> > > >
> > > >
> > > > I think we need to visit this issue on a case-by-case basis.   
> > > > Sometimes dprintk is appropriate.  Sometimes printk(KERN_ERR).   
> > > > Sometimes a performance metric.
> > > Well said.
> > > 
> > > > Trond has always maintained that dprintk() is best for developers, but  
> > > > probably inappropriate for field debugging,
> > > It's not a perfect tool but it beats nothing at all.
> > > >  and I think that may also  
> > > > apply to trace points.  
> > > It depends on whether distros can be convinced to enable it by default,
> > > and install by default any necessary userspace infrastructure.   The
> > > most important thing for field debugging is Just Knowing that you have
> > > all the bits necessary to perform useful debugging without having to
> > > find some RPM that matches the kernel that the machine is actually
> > > running now, and not the one that was present when the machine was
> > > installed.
> > 
> > Exactly, that is why an ftrace plugin, that only when selected using
> > echo "nfs" > /debug/tracing/current_tracer will activate the tracepoints
> > and provide output via /debug/tracing/trace or /deb/tracing/trace_pipe,
> > possibly combined with other ftrace plugins such as the stacktrace,
> > blktrace, etc.
> > 
> > I.e. no need at all for any matching userspace tool, near zero impact
> > when not activated, useful, if done right, for both developers and for
> > admins.
> > 
> > Again, an example can be found in the blktrace ftrace plugin[1], that
> > instead of adding a requirement will eventually drop an existing, well
> > established one (blktrace(8)).
> 
> I must be missing something. Exactly what functionality does this then
> give us that we don't have already with the existing RPC/NFS dprintk()
> scheme?

Filtering by CPU, the possibity of printing stack traces when the
tracepoints are hit, combination with other tracers to try to mix events
and correlate problems, a request may be taking too long because some
problems are happening on a lower layer subsystem that has, in turn,
tracepoints exposed thru another ftrace plugin.

But then I haven't looked too closely to the places that are being
proposed for conversion to tracepoints in NFS land, will do.

- Arnaldo
