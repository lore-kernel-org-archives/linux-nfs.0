Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:47536 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306Ab2BHOQA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 09:16:00 -0500
Date: Wed, 8 Feb 2012 09:15:52 -0500
From: Jim Rees <rees@umich.edu>
To: David Howells <dhowells@redhat.com>
Cc: jmorris@namei.org, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate
 name service errors
Message-ID: <20120208141552.GA3273@umich.edu>
References: <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
 <20120208122917.8902.78395.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120208122917.8902.78395.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells wrote:

  Define ENAMEUNKNOWN to indicate "Network name unknown".  This can be used to
  indicate, for example, that an attempt was made by dns_query() to make a query,
  but the name server (e.g. a DNS server) replied indicating that it had no
  matching records.

Would this be the same as NXDOMAIN?  That is, does it mean the name server
couldn't find a record, or does it mean that the record doesn't exist?
