Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754965AbdELN1X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 May 2017 09:27:23 -0400
Date: Fri, 12 May 2017 09:27:21 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170512132721.GA654@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
I've been working on NFS over the AF_VSOCK transport
(https://www.spinics.net/lists/linux-nfs/msg60292.html).  AF_VSOCK
resets established network connections when the virtual machine is
migrated to a new host.

The NFS client expects file handles and other state to remain valid upon
reconnecting.  This is not the case after VM live migration since the
new host does not have the NFS server state from the old host.

Volatile file handles have been suggested as a way to reflect that state
does not persist across reconnect, but the Linux NFS client does not
support volatile file handles.

I saw NFS 4.1 has a way for a new server running with the same network
address of an old server to communicate that it is indeed a new server
instance.  If the server owner/scope in the EXCHANGE_ID response does
not match the previous server's values then the server is a new
instance.

The implications of encountering a new server owner/scope upon reconnect
aren't clear to me and I'm not sure to what extent the Linux
implementation handles this case.  Can anyone explain what happens if
the NFS client finds a new server owner/scope after reconnecting?

Thanks,
Stefan

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZFbg5AAoJEJykq7OBq3PILB4IAJpZ7PaJzw9ClUMTQcvgjMGi
50i+v64yRyX3h4WbX3kgd7o5iJjviUMgUBjs2pwSi7PP/9R+owkP1OsnI6wmrqCy
gVHbnL18qVDrA+MsTpBIYmz8GIOG664ylsca/C5qv0JHal5j1wgN6TvYAofjrfKh
imJBlf6ByrYhiUCHTCI3OOODut6irBiwS2CXup9tcsNyFOgAkuDLsNFy5B1DpeU3
8ecOZOY3RRkXck/zyGmKuG3WkuyDLorwuiM+8kPVxhpG9ipiUPmoCQy7mHo5iDDs
+UtbSZqYIeDgywOKOcrjJdQrkKMCa4usqlhCPUiEXJBqZ39f6DG+RyEZ88J6Cbw=
=Q0WZ
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
