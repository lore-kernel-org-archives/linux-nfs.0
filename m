Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7728 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576Ab1CWTup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 15:50:45 -0400
Message-ID: <4D8A4F2B.5040007@panasas.com>
Date: Wed, 23 Mar 2011 21:51:07 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 09/12] NFSv4.1: remove GETATTR from ds commits
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com> <1300886875-5016-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-10-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-23 15:27, Fred Isaman wrote:
> Any COMMIT compound directed to a data server needs to have the
> GETATTR calls suppressed.  We here, make sure the field we are testing

s/We/While/?

Benny

> (data->lseg) is set and refcounted correctly.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
