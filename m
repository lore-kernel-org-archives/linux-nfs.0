Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32279 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757593Ab2HJVWb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 17:22:31 -0400
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120810203930.GC17985@fieldses.org>
Date: Fri, 10 Aug 2012 17:22:17 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Message-Id: <B38BE4A7-1D82-4B0D-9E71-2C35A1EB30D3@oracle.com>
References: <20120809193743.GD10591@fieldses.org> <20120809203838.GA11538@fieldses.org> <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com> <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com> <20120809211340.GB11538@fieldses.org> <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com> <20120809213838.GC11538@fieldses.org> <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com> <20120810201348.GB17985@fieldses.org> <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com> <20120810203930.GC17985@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 10, 2012, at 4:39 PM, J. Bruce Fields wrote:

> On Fri, Aug 10, 2012 at 04:33:46PM -0400, Chuck Lever wrote:
>> OK, I didn't notice that you were unmounting between the tests.  3.5 and before did update the boot verifier after the last mount of a server goes away, but that's also not desirable behavior.  So I guess 3.6 also has my patch which makes the NFS client use the same boot verifier until it reboots, as God and the authors of 3530 intended?
> 
> I don't know.  (Why is that the right thing to do?  Telling the server
> when you're not using the client any more seems reasonable to me.)

The pre-3.6 Linux NFS client uses a different nfs_client_id4.id string for every server address, even server addresses that happen to be endpoints for the same server instance (multi-homed servers).

That means the id and verifier are associated with a struct nfs_client.  The id, because it gets the server's presentation address from the nfs_client; and the verifier, because the verifier is stored in the nfs_client itself.

That struct nfs_client goes away when the client unmounts the last share on a server address.  The next mount of that server address will get a new nfs_client and thus a fresh verifier.  The id string stays the same, but is unique for that server address, so the apparent reboot should not interfere with other leases on that server.

If the client uses the same id string for all server addresses (and I explain below why we want to go there) this changes things.  If the client completely unmounts and remounts one of the server's addresses, the new nfs_client will contain a fresh boot verifier, but the id string is the same as the one the client uses on all the other server addresses.  And that will result in the client's next SETCLIENTID canceling its own leases on the other server addresses for that server.

So, if the client uses one id string for all servers, it must also use one boot verifier for all servers, to avoid clobbering its own leases on multi-homed servers.

Having a single atomic client instance <id, verifier> is critical for making Transparent State Migration work properly.  A destination server can not recognize migrated leased state for a client if the id string and boot verifier can't be matched to it because the client uses a different boot verifier and id string for every server it talks to.


Can you explain why you think its a better idea for the client to remove its lease?  For 4.0, it's never had to do that before.  The case you've hit worked before by establishing an additional lease rather than by zapping the old one, for example.

Moreover, it shouldn't matter much that a client doesn't tell a server when it's done, since the client's leases will quickly expire.  Generally the client cleans up everything but the lease and clientid4 when it unmounts, unless the client crashes, which is hopefully rare (and couldn't result in an "I'm done" notification anyway).  So, I don't see how leaving a lease could be a significant server-side resource issue, or how it might interfere with the operation of other clients.


> 
>> I think we agree that, whether the Linux server is compliant with what's currently in 3530bis or not, it's the NFS client changes in 3.6 that "introduced the regression" and should be fixed.  If you change the client to add the flavor and pseudoflavor name to the nfs_client_id4.id string, does that fix the regression satisfactorily?
> 
> I haven't tested it, but yes, that should do the job.
> 
> (Though note that's not just a revert, since previously only the flavor
> (not the pseudoflavor) was factored into the clientid string.)

Correct, that fix is not a revert.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




