Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:37180 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2E2FJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 01:09:38 -0400
Date: Tue, 29 May 2012 00:09:27 -0500
From: Jonathan Nieder <jrnieder@gmail.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: Trond.Myklebust@netapp.com, rees@umich.edu, bharrosh@panasas.com,
        linux-nfs@vger.kernel.org, stable@vger.kernel.org,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH-v2] pnfsblock: bail out partial page IO
Message-ID: <20120529050927.GB14016@burratino>
References: <1338265793-11387-1-git-send-email-bergwolf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338265793-11387-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Peng Tao wrote:

> Current block layout driver read/write code assumes page
> aligned IO in many places. Add a checker to validate the assumption.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Peng Tao <tao.peng@emc.com>

Does this fix a build error, oops, hang, data corruption, real
security issue, or other important bug that has been bothering people?

If so, please add a few more words explaining the symptoms in the
commit log.  If not, it sounds like a good change but it wouldn't be
suitable for stable.

Hope that helps,
Jonathan
