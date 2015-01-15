Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbbAOLUq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 06:20:46 -0500
Message-ID: <54B7A28C.9030201@RedHat.com>
Date: Thu, 15 Jan 2015 06:20:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH 0/3] Miscellaneous systemd changes (v2)
References: <1421250410-7246-1-git-send-email-steved@redhat.com>
In-Reply-To: <1421250410-7246-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/14/2015 10:46 AM, Steve Dickson wrote:
> v2:
>   * Corrected the numerous BindTo typos 
> 
> Here are a few systemd changes that were suggested
> by the systemd folks:
> 
>    * Bind the nfs-idmap service to the nfs server.
>    * Correctly bind nfs-mountd service to the nfs server.
>    * Used approved way to check if systemd is install and running
> 
> Steve Dickson (3):
>   systemd: Bind rpc.idmapd to the nfs-server service
>   systemd: Bind the nfs-mountd service to the nfs-server service
>   start-statd: Use the canonical to check if systemd is running.
> 
>  systemd/nfs-idmapd.service | 2 +-
>  systemd/nfs-mountd.service | 3 +--
>  utils/statd/start-statd    | 2 +-
>  3 files changed, 3 insertions(+), 4 deletions(-)
> 
All three committed.... 

steved.
