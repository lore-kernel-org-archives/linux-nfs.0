Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:56251 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751708Ab2AZOzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 09:55:24 -0500
Date: Thu, 26 Jan 2012 09:55:20 -0500
From: Jim Rees <rees@umich.edu>
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com, chuck.lever@oracle.com,
        bharrosh@panasas.com
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
Message-ID: <20120126145520.GA10112@umich.edu>
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You may want to read the mailing list thread from the earlier patch.  I
don't remember the details but lowering the panic timeout from 110 to 41
seconds may re-introduce the problem that patch was trying to solve.  You
could increase the retry count to compensate.
