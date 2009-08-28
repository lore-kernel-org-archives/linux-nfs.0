From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or
	"vers=4" option are set (vers-02)
Date: Fri, 28 Aug 2009 12:59:53 -0400
Message-ID: <20090828165953.GA11009@infradead.org>
References: <F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
	<4A95760C.9000604@RedHat.com>
	<B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
	<1251316764.5226.21.camel@heimdal.trondhjem.org>
	<4A9694D2.2030205@RedHat.com>
	<4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
	<20090828161256.GA2859@infradead.org> <4A980751.7070206@RedHat.com>
	<20090828164154.GB9951@infradead.org> <4A980B6D.4010306@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A980B6D.4010306@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 12:53:01PM -0400, Steve Dickson wrote:
> > As soon as it doesn't work return an error, unwind
> > and return to userspace?
> Then why not simply stay in user space?

I just told you the merging the two file_system_type implementations
(actually more than two, for some reason nfs alone has more than all
other network filesystems combined) is easy and beneficial for the
quality of the kernel code.  If there's something in the behaviour
of the userspace mount helpers not actually making it useful it's
up to you to decide if you want to do it or not.
