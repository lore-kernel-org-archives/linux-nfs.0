From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] nfsmount.conf: New variables that explicitly set default (Release 3)
Date: Tue, 20 Oct 2009 22:27:36 +0900
Message-ID: <72A8F3EA-BEDD-416A-9CBF-D15E12EC4E4F@oracle.com>
References: <4AD9C871.3000400@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56558 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZJTN2I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 09:28:08 -0400
In-Reply-To: <4AD9C871.3000400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 17, 2009, at 10:36 PM, Steve Dickson wrote:

> Here is an update to my previous patch that allow the setting
> of both the protocol version and network version from the
> mount configuration file. Here is the original justification:
>
>    http://marc.info/?l=linux-nfs&m=125511238831199&w=2
>
> In this release two global variables are used to keep
> the default values set in the configuration file. These
> values are then used to initialize the values used in
> the server negotiation.
>
> This patch set can be found on the 'mntconf_v3' branch
> on my experimental git tree:
>    git://linux-nfs.org/nfs-utils-exp
>
>
> Comments?

Much simpler, eh?  I think this is closer but I would like to study it  
a little more.  I will post more specific comments tomorrow.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



