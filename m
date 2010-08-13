Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vasily.name ([208.84.148.235]:34760 "EHLO vasily.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab0HMWq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 18:46:56 -0400
Date: Fri, 13 Aug 2010 18:34:51 -0400
From: Vasily Tarasov <tarasov@vasily.name>
To: Risto Bell <reb@cypress.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS and file locking for use with sqllite
Message-ID: <20100813223450.GC18210@vasily.name>
References: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com> <0C88B758-1DE8-4CFB-9546-A30104009A12@oracle.com> <AANLkTimqTvgyvvjP2R12wsdpZRs10T+YAtUGw7u6pxWZ@mail.gmail.com> <4C65C2A3.40404@cypress.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C65C2A3.40404@cypress.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You can read from /proc/locks file at the server. This will give you the list
of all locks on the server. Then you can filter out NFS relevant information,
say, based on the inode number.

Vasily

On Fri, Aug 13, 2010 at 03:09:39PM -0700, Risto Bell wrote:
> From client, how to remotely query server for list of locks held?
> Helpful if debugging lock recovery failures.
> 
> ---------------------------------------------------------------
> This message and any attachments may contain Cypress (or its
> subsidiaries) confidential information. If it has been received
> in error, please advise the sender and immediately delete this
> message.
> ---------------------------------------------------------------
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
