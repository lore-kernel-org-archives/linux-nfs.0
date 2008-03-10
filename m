From: Andreas Dilger <adilger@sun.com>
Subject: Re: [PATCH 0/3] enhanced ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 16:42:32 -0600
Message-ID: <20080310224232.GM5851@webber.adilger.int>
References: <4790C756.2040704@redhat.com> <47A387C9.1000506@redhat.com>
 <47D598BD.9050604@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_LxckJSbeSJTyJeBhG1PUsw)"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755375AbYCJWnr@vger.kernel.org>
In-reply-to: <47D598BD.9050604@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Boundary_(ID_LxckJSbeSJTyJeBhG1PUsw)
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline

On Mar 10, 2008  16:23 -0400, Peter Staubach wrote:
> Here is version 3 of a patch set which modifies the system to
> enhance the ESTALE error handling for system calls which take
> pathnames as arguments.  This patch set is essentially the
> same as the v2 patches, but updated to reflect the current
> state of the code around them.

[snip long discussion of ESTALE causes]

> This support was tested using the attached programs and
> running multiple copies on mounted file systems which do not
> share superblocks.  When two or more copies of this program
> are running, many ESTALE errors can be seen over the network.
> Without these patches, the test program errors out almost
> immediately.  With these patches, the test program runs
> for as long one desires.

Have you tried "racer.sh"?  That is a very stressful metadata tester
that does random operations on a handful of file and directory names.
It can be run on a single client, or on multiple clients and needs no
coordination between the clients.  I guess it won't tell you if you
are getting ESTALE back correctly or not, but it can quickly find if
there are any problems with the retrying code.

I've attached an updated tarball of the original scripts here.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.


--Boundary_(ID_LxckJSbeSJTyJeBhG1PUsw)
Content-type: application/x-gzip; NAME=racer-lustre.tar.gz
Content-transfer-encoding: BASE64
Content-disposition: attachment; filename=racer-lustre.tar.gz

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

--Boundary_(ID_LxckJSbeSJTyJeBhG1PUsw)--
