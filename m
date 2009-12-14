From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: Re: starting 90-second grace period : leasetime less than 10
Date: Mon, 14 Dec 2009 17:40:20 +0530
Message-ID: <f5b5ebae0912140410t2814d7bck688549103b3104ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:60494 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757127AbZLNMNw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2009 07:13:52 -0500
Received: by iwn1 with SMTP id 1so99584iwn.33
        for <linux-nfs@vger.kernel.org>; Mon, 14 Dec 2009 04:13:50 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can not set nfs4leasetime value less than 10 seconds.

there is a verification in __write_leasetime(). (lease < 10 || lease > 3600)

I am going to change this to ~2 second (to make NFS HA failover happen
in less than 10 seconds with HeartBeat).

Any reason why is this checked for 10 (i.e. lease < 10) ... ?





static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
{
        /* if size > 10 seconds, call
         * nfs4_reset_lease() then write out the new lease (seconds) as reply
         */
        char *mesg = buf;
        int rv, lease;

        if (size > 0) {
                if (nfsd_serv)
                        return -EBUSY;
                rv = get_int(&mesg, &lease);
                if (rv)
                        return rv;
                if (lease < 10 || lease > 3600)
                        return -EINVAL;
                nfs4_reset_lease(lease);
        }

        return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
                                                        nfs4_lease_time());
}

-- 
Tharindu Rukshan Bamunuarachchi
