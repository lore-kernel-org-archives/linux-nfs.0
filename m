Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23693 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159Ab0GANua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jul 2010 09:50:30 -0400
Message-Id: <7B1AD6D8-4D7D-48B6-9439-7A1469784754@netapp.com>
From: Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: get_lock_alloc_layout
Date: Thu, 1 Jul 2010 09:50:11 -0400
Cc: "linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Benny

Why do we have the complexity of waiting on a bit lock for allocating  
a layout? Why can't we use the normal form:

take the i_lock
lookup layout
if (layout == NULL) {
         give up i_lock
         allocate and init new layout
                return NULL if allocation fails
         take the i_lock
         lookup layout
         if (layout == NULL)
                 set new layout for return
         else
                 set found layout for return
}
give up i_lock
if new was allocated and not used
           free the new layout
return layout


-->Andy

  
