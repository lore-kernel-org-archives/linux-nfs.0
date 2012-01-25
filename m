Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:37668 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750876Ab2AYScH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 13:32:07 -0500
Date: Wed, 25 Jan 2012 13:32:00 -0500
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
        linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
Message-ID: <20120125183200.GA26907@umich.edu>
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com>
 <4F202BD4.5020400@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F202BD4.5020400@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  On 01/25/2012 04:50 PM, Srinivas KANDAGATLA wrote:
  > From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
  > 
  > This patch adds mountretry kernel parameter for nfs root mount.
  > mount retry indicates the number of times nfs root mount attempts to be
  > made before giving up. If this option is not specified, the default
  > value of 3 retries is used.
  > 
  
  If the system is set to have root on NFS. And the root is not found
  what does it do? does it Just bums out with a recovery console?
  
  So what better options does it have other then retry for ever. die?
  
  I always thought that was inconsistent. With an hard mount NFS
  will never give up and will retry for ever freezing all IOers until
  the server came back. Only with root-mount it gives up.
  
  Please explain what is the benefits of giving up at all. Can a machine
  be at all usable without it's root? 

Doesn't grub have some fallback logic in case the given kernel/root fails?
Also, don't you want some indication that it's not working other than just a
blank screen?
