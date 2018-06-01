Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:37342 "EHLO
        mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbeFAMNH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 08:13:07 -0400
Received: from localhost (localhost [127.0.0.1])
        by amavis (Postfix) with ESMTP id DF1CC640066
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 14:07:03 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.73])
        by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id 0a5AgP3XCCrJ for <linux-nfs@vger.kernel.org>;
        Fri,  1 Jun 2018 14:07:03 +0200 (CEST)
Received: from smtp-a.tudelft.nl (smtp-a.tudelft.nl [131.180.190.158])
        by mx2.tudelft.nl (Postfix) with ESMTP id 7DF0F640097
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 14:07:03 +0200 (CEST)
Received: from [131.180.203.163] (tud208172.ws.tudelft.net [131.180.203.163])
        (using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
        (No client certificate requested)
        by smtp-a.tudelft.nl (Postfix) with ESMTP id 764891A40BF
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 14:07:03 +0200 (CEST)
To: linux-nfs@vger.kernel.org
From: Robbert Eggermont <R.Eggermont@tudelft.nl>
Subject: RPC UDP message size limit
Message-ID: <726a7d92-bcb0-6120-252c-26d3a0951ddc@tudelft.nl>
Date: Fri, 1 Jun 2018 14:07:03 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently we started hitting the libtirpc RPC UDP message size limit 
(tirpc/rpc/rpc.h: #define UDPMSGSIZE 8800) for 'showmount -e' from a 
NetApp filer (with around 25kB worth of exports). Only 8800 bytes are 
read, resulting in an abort with a "rpc mount export: RPC: Can't decode 
result" error.

Since it seems filers are already using a higher limit, should this 
limit be increased (at least for receiving, which should be safe)?

-- 
Robbert Eggermont
Intelligent Systems Support & Data Steward | TU Delft
+31 15 27 83234 | Building 28, Floor 5, Room W660
Available Mon, Wed-Fri
