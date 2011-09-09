Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758329Ab1IIKg5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 06:36:57 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1315243548-18664-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 14/26] richacl: Permission mapping functions
Date: Fri, 09 Sep 2011 11:36:10 +0100
Message-ID: <23273.1315564570@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:

> +unsigned int
> +richacl_want_to_mask(int want)

unsigned int want?

David
