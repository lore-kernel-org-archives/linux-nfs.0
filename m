Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from asavdk3.altibox.net ([109.247.116.14]:59244 "EHLO
        asavdk3.altibox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbeA1UOi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 15:14:38 -0500
Date: Sun, 28 Jan 2018 21:08:30 +0100
From: Sam Ravnborg <sam@ravnborg.org>
To: James Ettle <james@ettle.org.uk>
Cc: linux-nfs@vger.kernel.org, sparclinux@vger.kernel.org
Subject: Re: Unaligned access in gss_{get,verify}_mic_v2() on sparc64
Message-ID: <20180128200830.GA30041@ravnborg.org>
References: <55549068-2605-7f71-ccef-c102d6fd69ab@ettle.org.uk>
 <20171206190936.GB5875@fieldses.org>
 <8d4f1809-5027-46e7-1d21-d55f93950693@ettle.org.uk>
 <2fad5cab-915c-a224-a1f1-b96a77a8546d@ettle.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2fad5cab-915c-a224-a1f1-b96a77a8546d@ettle.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 28, 2018 at 04:34:57PM +0000, James Ettle wrote:
> Hi,
> 
> Just a polite prod in case it's fallen off the radar. The patch in this thread still applies cleanly to 4.14.15.
I would recommend you to send this as a new mail - with a proper [PATCH] in the title.
Otherwise it may not be picked up.

Posting a patch in the midle of a thread is no-go.

	Sam
