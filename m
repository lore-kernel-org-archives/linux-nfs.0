Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:54569 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbbANQvi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:51:38 -0500
Received: by mail-vc0-f171.google.com with SMTP id hy4so3207101vcb.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:51:37 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 14 Jan 2015 11:51:37 -0500
Message-ID: <CAHQdGtTqYi0krW6b9w0Bxe-UJkP1nPZEJdCEMYb5XTA91rBtLw@mail.gmail.com>
Subject: Race in bl_resolve_deviceid?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

bl_resolve_deviceid() has:

        add_wait_queue(&nn->bl_wq, &wq);
        rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
        if (rc < 0) {
                remove_wait_queue(&nn->bl_wq, &wq);
                goto out_free_data;
        }

        set_current_state(TASK_UNINTERRUPTIBLE);
        schedule();
        remove_wait_queue(&nn->bl_wq, &wq);


Doesn't that call to 'set_current_state()' need to come before the
rpc_queue_upcall() if you want the wait for the downcall to be
race-free? It looks to me as if the right thing to do here is to
replace the above with a prepare_to_wait()/finish_wait() pair...

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
