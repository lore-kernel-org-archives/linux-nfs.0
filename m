Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:51156 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2A0Med (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jan 2012 07:34:33 -0500
Date: Fri, 27 Jan 2012 07:34:26 -0500
From: Jim Rees <rees@umich.edu>
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com, bharrosh@panasas.com, linux@razik.name
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
Message-ID: <20120127123426.GA3089@umich.edu>
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
 <EBFEB6A8-4943-4D9E-9139-73D14ACB32DD@oracle.com>
 <4F225BED.7000005@st.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F225BED.7000005@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I hate timeouts.  Isn't there some way to wait until the interface is up
before attempting the mount?
