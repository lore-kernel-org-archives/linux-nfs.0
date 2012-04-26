Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47550 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab2DZTD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 15:03:26 -0400
Date: Thu, 26 Apr 2012 15:03:24 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Linux server client ID behavior
Message-ID: <20120426190324.GA9920@fieldses.org>
References: <CDACC8A7-C94B-4F03-B355-33B42686BD1B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CDACC8A7-C94B-4F03-B355-33B42686BD1B@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 12:17:13PM -0400, Chuck Lever wrote:
> Hi-
> 
> Follow up on the issue I reported in IRC a couple of days ago.
> 
> I'm using a stock Fedora 16 NFS server and my prototype UCS client.  The client uses the same nfs_client_id4 string and boot verifier for all mounts on all servers.  It performs a SETCLIENTID as part of the mount operation.  SETCLIENTID is the first NFS operation after the client sends it's NFS ping.
> 
> The test is simple.  It is meant to see if the UCS client recognizes that a server with an IPv4 and IPv6 address (a very typical configuration) is effectively trunked.  It goes like this:
> 
>   1.  Mount a filesystem on a server on it's IPv4 address via NFSv4.0
>   2.  Without unmounting the first filesystem, and without letting the first lease expire, mount a different filesystem on the same server on it's IPv6 address via NFSv4.0
> 
> The Solaris 11 FCS server allows both mounts, and the client recognizes that the IPv4 and IPv6 address represent the same server instance.  Based on Noveck's NFSv4 migration draft, I believe this is the correct outcome.
> 
> With the Fedora 16 (3.3.2-1) Linux NFS server, the following is observed:
> 
>   a.  The second (IPv6) mount sends a SETCLIENTID with the same nfs_client_id4 and boot verifier as the first mount, as expected.  The request succeeds, and the server returns a different clientid4 than the first mount.  I believe that's incorrect.
> 
> The server should return the same clientid4 as the first SETCLIENTID operation, since the client has presented the same nfs_client_id4 and boot verifier.  The nfs_client_id4 string alone is how servers should detect client identity.  For non-UCS clients, this should be enough anyway, since IP addresses are already embedded in the string.  [ I have not yet tried this test with NFSv4.1, where all clients are supposed to use UCS. ]
> 
>   b.  The second (IPv6) mount then sends a SETCLIENTID_CONFIRM and the server replies with NFS4ERR_CLID_INUSE.  I believe CLID_INUSE is an incorrect response.
> 
> My reading of 3530bis is that CLID_INUSE is appropriate only when there is an authentication flavor mismatch on SETCLIENTID or SETCLIENTID_CONFIRM requests.  That is, the client has previously presented the nfs_client_id4 string using a different authentication flavor than the one it is using in the current request, and the lease that resulted from that previous operation has not yet expired.  In this case, the authentication flavor (AUTH_SYS) is the same on both SETCLIENTID operations, so SETCLIENTID_CONFIRM should be treated as a valid request from this client.
> 
> The larger concern is that we have here another example of a widely deployed server implementation that does not tolerate UCS clients.  Before I report this experience to the working group, I would like comment on the Linux server's behavior and my opinions about its correctness.

I agree, both sound like bugs.  (Could you make patches?)

The second is easy to fix.  From a quick look at historical git
archives, it appears to have been there from the beginning.

The first I don't understand.  It certainly doesn't look like what the
code's intended to do on a quick glance, so there must be some logic
error I'm not seeing....

--b.
