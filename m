Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753072AbeDBSab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Apr 2018 14:30:31 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Orion Poplawski" <orion@nwra.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS troubles
Date: Mon, 02 Apr 2018 14:30:29 -0400
Message-ID: <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
In-Reply-To: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4ERR_EXPIRED means the client is trying to use state that the server 
believes to have expired or that has been supplanted by newer state.  
Can we get kernel versions for the client and server?  Have you talked 
to your Red Hat support channel about this?

This capture doesn't appear to show any bugs or bad behaviors, but a 
longer capture may..

Ben

On 2 Apr 2018, at 13:50, Orion Poplawski wrote:

> I'm having a lot of trouble with NFS going out to lunch between my 
> RHEL7
> machines.  Users cannot access files, and get errors like:
>
> $ touch blah
> touch: cannot touch ‘blah’: Input/output error
>
> I'm attaching a pcap trace of the above touch during the problem.  It 
> seems
> that the server is returning NFS4ERR_EXPIRED.
>
> Reboots/restarts of nfs help for a bit but then the problems return.
>
> Other symptoms of trouble are messages like:
>
> RPC: fragment too large: 613351424
>
> on the client.
>
> Any help with trying to track this down would be greatly appreciated.
>
> -- 
> Orion Poplawski
> Manager of NWRA Technical Systems          720-772-5637
> NWRA, Boulder/CoRA Office             FAX: 303-415-9702
> 3380 Mitchell Lane                       orion@nwra.com
> Boulder, CO 80301                 https://www.nwra.com/
