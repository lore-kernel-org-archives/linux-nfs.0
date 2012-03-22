Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:40644 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758307Ab2CVDAY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 23:00:24 -0400
Date: Thu, 22 Mar 2012 14:00:00 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Boaz Harrosh <bharrosh@panasas.com>
cc: Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 2/4] kmod: Convert two call sites to
 call_usermodehelper_fns()
In-Reply-To: <4F691217.5070108@panasas.com>
Message-ID: <alpine.LRH.2.02.1203221358470.13437@tundra.namei.org>
References: <4F691059.30405@panasas.com> <4F691217.5070108@panasas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 Mar 2012, Boaz Harrosh wrote:

> 
> Both   kernel/sys.c && security/keys/request_key.c where inlining the exact same
> code as call_usermodehelper_fns(); So simply convert these sites to directly
> use  call_usermodehelper_fns().
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Reviewed-by: James Morris <james.l.morris@oracle.com>


-- 
James Morris
<jmorris@namei.org>
