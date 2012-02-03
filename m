Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:46076 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756164Ab2BCNQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 08:16:44 -0500
Date: Fri, 3 Feb 2012 08:16:36 -0500
From: Jim Rees <rees@umich.edu>
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com, bharrosh@panasas.com, linux@razik.name
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
Message-ID: <20120203131636.GA8220@umich.edu>
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
 <EBFEB6A8-4943-4D9E-9139-73D14ACB32DD@oracle.com>
 <4F225BED.7000005@st.com>
 <4F2BB2C0.9060207@st.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F2BB2C0.9060207@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems confusing to change the meaning of NFSROOT_TIMEOUT_MIN.  It used to
be the timeout minimum, as the name implies, but now it's the timeout
minimum plus one.  I understand that the actual timeout includes the time
spent in mount, but I would expect NFSROOT_TIMEOUT_MIN to just be the
initial loop sleep time.  Maybe this just needs a comment.
