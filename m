From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Subject: NFS4ERR_RESOURCE in setclientid_confirm
Date: Mon, 02 Mar 2009 12:32:21 -0500
Message-ID: <49AC1825.2050609@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.uvm.edu ([132.198.101.168]:48369 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907AbZCBRcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 12:32:24 -0500
Received: from planck.local ([132.198.107.214])
	(authenticated bits=0)
	by smtp1.uvm.edu (8.14.2/8.14.2) with ESMTP id n22HWLJa012264
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 2 Mar 2009 12:32:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Should we be checking for EREMOTEIO in nfs4_proc_setclientid_confirm 
instead of NFS4ERR_RESOURCE to get the delay/retry, because its 
converted in decode_op_hdr?  Would it be safe to remove this entry from 
the error table?

Ben
