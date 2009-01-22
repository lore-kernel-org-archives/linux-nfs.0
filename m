From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 11:45:03 -0500
Message-ID: <20090122164503.GC13129@fieldses.org>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<49777988.6010401@RedHat.com>
	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
	<4977A385.8000406@melbourne.sgi.com>
	<20090121225619.GI4295@fieldses.org> <497897F5.9030005@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap@sources.redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Greg Banks <gnb@melbourne.sgi.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <497897F5.9030005@RedHat.com>
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

On Thu, Jan 22, 2009 at 10:59:49AM -0500, Steve Dickson wrote:
> J. Bruce Fields wrote:
> > 
> > On the mount case specifically: How far are we from the idea of a mount
> > program that can identify most problems itself?  I know its error
> > reporting has gotten better....
> > 
> > I suppose the main feedback mount gets right now is an error code from
> > the mount system call, and that may be too narrow an interface to cover
> > most problems.  Is there some way we can give mount a real interface it
> > can use to find out this stuff instead of just dumping more strings into
> > the logs?
> Interesting.... Store something like a reason code (similar to what they have
> in he Kerberos)

Maybe.

> in somewhere in the proc file system? 

But then I don't know how you'd associate it with a particular mount
attempt.

--b.

> Its seems to me this is a common problem among network file systems... 
