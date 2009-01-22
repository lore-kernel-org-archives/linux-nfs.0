From: fche@redhat.com (Frank Ch. Eigler)
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 19:53:44 -0500
Message-ID: <y0m63k8tb3b.fsf@ton.toronto.redhat.com>
References: <4970B451.4080201@RedHat.com> 	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> 	<497757D1.7090908@RedHat.com> 	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com> 	<49777988.6010401@RedHat.com> 	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com> 	<4977A385.8000406@melbourne.sgi.com> 	<1232578570.7692.96.camel@heimdal.trondhjem.org> 	<4977AB86.4030603@melbourne.sgi.com> 	<1232581675.7692.121.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>, nfsv4@linux-nfs.org,         Linux NFS Mailing list <linux-nfs@vger.kernel.org>,         SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <systemtap-return-10984-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <1232581675.7692.121.camel@heimdal.trondhjem.org> (Trond Myklebust's message of "Wed, 21 Jan 2009 18:47:55 -0500")
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> [...]  As I understand it, you are not only proposing to make that
> filter extremely fine (individually addressable trace points), but
> also to enable the application of scripting tools like systemtap and
> LTTng in order to provide bespoke debugging of your customer
> problems. Have I misunderstood you, or is that correct?

Perhaps.

> The question then is how is this going to work out in an environment
> where the individually addressable trace points/dprintk()s pop in
> and out of existence at the whim of a patch, and where the output
> format is similarly volatile?

It would work no worse than what there is now.  For environments where
the code is not subject to that much patching, it could be
piggybacked-upon for more analysis.

> IOW: I'm referring to the difference between an interface that was
> designed purely to be interpreted by humans, and one that is
> designed from scratch to be interpreted by scripts.

It need not be a disjunction.  As more formal machine-oriented
interfaces come into existence, the same tools can shift focus to
them.  Depending on the tool, the shift may be nearly invisible to a
naive end user.


- FChE
