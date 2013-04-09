Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759626Ab3DITmB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 15:42:01 -0400
Message-ID: <51646EF4.5010405@RedHat.com>
Date: Tue, 09 Apr 2013 15:41:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [PATCH 0/2] libtirpc and nfs-utils fix for export lucid context
References: <1365201425-21702-1-git-send-email-simo@redhat.com>
In-Reply-To: <1365201425-21702-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/04/13 18:37, Simo Sorce wrote:
> The following 2 patches go in tandem.
> One is for libtirpc and the other for nfs-utils.
How backwards compatible are these patches?

Meaning will a patched nfs-utils work with a non-patch libtirpc and vises versus?
It appears that is the case... I just want to make sure I'm not missing 
something... 


steved. 
> 
> The standard gss_krb5_export_lucid_sec_context call actually deletes the gss context
> after it has been exported, so these patches perform a complete hand over of the
> context from libtirpc, so that the context handle can be nulled out in the
> gss_krb5_export_lucid_sec_context and the code does not attempt to free it
> twice and cause segmentation faults in the unlucky case.
> 
