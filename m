From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 15:47:29 -0200
Message-ID: <20090122174729.GG5184@ghostprotocols.net>
References: <4970B451.4080201@RedHat.com> <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> <497757D1.7090908@RedHat.com> <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com> <1232566140.7692.64.camel@heimdal.trondhjem.org> <49777E4C.2020501@RedHat.com> <1232569427.7692.70.camel@heimdal.trondhjem.org> <49786F9F.7030400@RedHat.com> <1232638257.7589.16.camel@heimdal.trondhjem.org> <49789597.8030504@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,         Chuck Lever <chuck.lever@oracle.com>,         Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,         Linux NFS Mailing list <linux-nfs@vger.kernel.org>,         SystemTAP <systemtap@sources.redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <systemtap-return-11001-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <49789597.8030504@RedHat.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>

Em Thu, Jan 22, 2009 at 10:49:43AM -0500, Steve Dickson escreveu:
> 
> 
> Trond Myklebust wrote:
> > On Thu, 2009-01-22 at 08:07 -0500, Steve Dickson wrote:
> >>> I think it might be a good idea to flesh out a bit what you mean by
> >>> "debugging" here. Since you mentioned it in conjunction with the two
> >>> words "administrators" and "scripts", I assume that you are not talking
> >>> about kernel code debugging?
> >> I'm talking debugging for both admins and kernel people...
> >>
> >> With trace points and systemtap you can do both.
> > 
> > Yes, but we still need to figure out details of what each type of user
> > is expecting/wants.
> Will that be possible? Until we get something in their hands, how will
> they even know what they want or need.
> 
> > 
> > I suspect that when we get down to cases, we will find that a lot of the
> > tracepoints that administrators find useful will want to be put in the
> > VFS rather than in the filesystems themselves. If you have tracepoints
> > in sys_stat() and sys_fstat(), why would you also need a tracepoint in
> > nfs_getattr()? AFAICS, that would just make scripting ugly...
> I believe there is an effort to do some type of system call tracing 
> as we speak and that effort should be followed to ensure there is
> no duplicate of effort... But in the end, I would think more would be
> better then less... since each point can be explicitly enabled and disabled
> a little duplication may not be all that bad..

I believe that the use case scenario here is blktrace, it was done
before tracepoints were in the kernel, before developers thought that
not requiring whatever size/complexity userspace binary to grok whatever
fast/optimum way to relay data so as some userspace tool would
inteligently process.

Now we're trying to keep the existing developer assists and augment it
with other, standardized ways coming for other subsystems, looking at
how to get the best ways of every trace-me-harder approach previously
endeavoured.

tracepoints, ftrace, etc, are an excellent opportunity for people to go
from stone age
print-msg-that-could-be-interesting-to-some-class-of-observer to
something OS provided, highly optimized.

<expletives deleted>

Erm, what is it that you think should be covered in a from everybody in
this community tracing perspective point of view?

- Arnaldo
