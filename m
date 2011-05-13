From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
Date: Fri, 13 May 2011 21:10:09 +0530
Message-ID: <87zkmqobhi.fsf__28252.5175637149$1305301253$gmane$org@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110228211145.GG28617@thunk.org> <E1QKJAl-00DGc7-EB@intern.SerNet.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: =?utf-8?Q?Bj=C3=B6rn?= JACKE <bj@SerNet.DE>,
	"Ted Ts'o" <tytso@mit.edu>, sfrench@us.ibm.com, agruen@linbit.com,
	dilger.kernel@dilger.ca, sandeen@redhat.com, bfields@fieldses.org,
	jlay
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:37921 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab1EMPk1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2011 11:40:27 -0400
In-Reply-To: <E1QKJAl-00DGc7-EB-dqLtpHMqGvUyWpdLl23E4A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 12 May 2011 00:16:13 +0200, Bj=C3=B6rn JACKE <bj@SerNet.DE> wro=
te:
> Hi,
>=20
> On 2011-02-28 at 16:11 -0500 Ted Ts'o sent off:
> > What is the current status of this patch series?  I seem to remembe=
r
> > that Christoph and Al Viro had some objections; have those been
> > cleared yet?  If not, can you summarize what their objections are?
> >=20
> > To be honest I haven't been paying super close attention to this pa=
tch
> > series, and I'm curious what needs to happen with it one way or
> > another.
>=20
> after the discussion of this path submission thread are there any maj=
or or
> minor issues left that prevent these to go upstream? I'd really love =
to see
> NFSv4 ACLs being available on Linux, too.
>=20

I updated richaclv23 branch at=20

http://git.kernel.org/?p=3Dlinux/kernel/git/kvaneesh/linux-richacl.git;=
a=3Dsummary

which is rebased against latest linus tree.  The changes pass richacl
test against local file system. I am yet to test richacl on NFS
client. Once i get the results i will repost the series again.=20

-aneesh
