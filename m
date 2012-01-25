Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:53680 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753020Ab2AYPpl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 10:45:41 -0500
Date: Wed, 25 Jan 2012 10:45:39 -0500
From: Jim Rees <rees@umich.edu>
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com
Subject: Re: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root
 mount.
Message-ID: <20120125154539.GA20734@umich.edu>
References: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Srinivas KANDAGATLA wrote:

  From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
  
  This patch adds mountretry kernel parameter for nfs root mount.
  mount retry indicates the number of times nfs root mount attempts to be
  made before giving up. If this option is not specified, the default
  value of 3 retries is used.

This has already been fixed in commit 43717c7d, "NFS: Retry mounting
NFSROOT".  The retry count is fixed at 5.  Is there some reason you think
the retry count should be configurable?
