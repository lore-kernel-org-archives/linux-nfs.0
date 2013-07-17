Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:35955 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755416Ab3GQUx5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:53:57 -0400
Message-ID: <1374094436.1949.109.camel@joe-AO722>
Subject: Re: [PATCH 02/10] Add a generic associative array implementation.
From: Joe Perches <joe@perches.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 13:53:56 -0700
In-Reply-To: <20130717204330.8591.39362.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
	 <20130717204330.8591.39362.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-07-17 at 21:43 +0100, David Howells wrote:
> Add a generic associative array implementation that can be used as the
> container for keyrings, thereby massively increasing the capacity available
> whilst also speeding up searching in keyrings that contain a lot of keys.

> +extern int assoc_array_iterate(const struct assoc_array *array,
> +			       int (*iterator)(const void *object, bool type,
> +					       void *iterator_data),
> +			       void *iterator_data);

bool type makes me queasy.


