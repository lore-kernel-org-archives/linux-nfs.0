Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433Ab3LQKUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Dec 2013 05:20:23 -0500
Message-ID: <52B0255E.6040503@redhat.com>
Date: Tue, 17 Dec 2013 11:20:14 +0100
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>, viro@ZenIV.linux.org.uk
CC: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        libc-alpha@sourceware.org, linux-api@vger.kernel.org,
        andreas.gruenbacher@gmail.com, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] statxat: Add a system call to make extended file
 stats available
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk> <20131112173534.25813.70732.stgit@warthog.procyon.org.uk>
In-Reply-To: <20131112173534.25813.70732.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2013 06:35 PM, David Howells wrote:
> 		uint64_t	st_ino;
> 		uint64_t	st_size;
> 		uint64_t	st_blocks;

Should this include zeroed fields for 128 bit forward compatibility?

Windows SIDs would be expressed as extended attributes and therefore are 
not needed to be presented here, correct?  What about the presence of 
alternate data streams/resource forks?

-- 
Florian Weimer / Red Hat Product Security Team
