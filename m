Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail09.linbit.com ([212.69.161.110]:37855 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368Ab1COIsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 04:48:00 -0400
From: Andreas Gruenbacher <agruen@linbit.com>
To: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
Date: Tue, 15 Mar 2011 09:46:41 +0100
Cc: "J. Bruce Fields" <bfields@fieldses.org>, "Ted Ts'o" <tytso@mit.edu>,
        sfrench@us.ibm.com, dilger.kernel@dilger.ca, sandeen@redhat.com,
        jlayton@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110305003214.GF21260@fieldses.org> <87pqq5a1qj.fsf@linux.vnet.ibm.com>
In-Reply-To: <87pqq5a1qj.fsf@linux.vnet.ibm.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201103150946.41554.agruen@linbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Aneesh,

On Saturday 05 March 2011 18:58:12 Aneesh Kumar K. V wrote:
> Andreas didn't like the compat feature flag patch. I don't remember why
> though. Andreas can you comment on why you didn't want the compat
> feature flag ?

The mount option made developing and testing of the patch set easier because
it didn't require a modification to e2fsprogs.  For upstream, the feature flag
(*) makes a lot more sense, though.

(*) http://git.kernel.org/?p=linux/kernel/git/kvaneesh/linux-richacl.git;h=fb5c519

Thanks,
Andreas
