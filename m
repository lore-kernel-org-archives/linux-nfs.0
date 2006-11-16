From: Open Source <opensource3141@yahoo.com>
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!
Date: Wed, 15 Nov 2006 18:31:17 -0800 (PST)
Message-ID: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

I think I have found the answer.  It is similar to this issue but not
exactly the same as:

http://linux-nfs.org/pipermail/nfsv4/2005-November/002807.html

Here's what is happening.  In 2.6.18 there is a new file called
fs/nfs/client.c.  In this file it does the following for every new
mount:

1) Lookup to see if an existing client has the same specification
as the requested mount.

2) If so, clone that client.  If not, create a new one.

3) Create any pipes required by the auth pseudoflavor by
calling rpcauth_create.

4) Continue with the mounting of the volume.

Now, if you have no connections to the server, a new rpc
client is created and the pipes are created with no problems.
For the second mount to the same server, the rpc client is
cloned and has the same path in /var/lib/nfs/rpc_pipefs/nfs
has the first connection.  Therefore on step 3 the pipe creation
fails in net/sunrpc/auth_gss/auth_gss.c.  This causes the
entire mount to fail.

This is a serious bug that prevents important functionality
of nfsv3 with krb5.  I notice that kernel 2.6.19 is on release
candidate 5.  Is there any way a surgical fix can be inserted
into 2.6.19 before final release?

This bug does not exist under 2.6.17 since client directories
in /var/lib/nfs/rpc_pipefs/nfs are not reused across different
nfsv3+krb5 mounts to the same server.

Thanks,
Paarvai


----- Original Message ----
From: Open Source <opensource3141@yahoo.com>
To: J. Bruce Fields <bfields@fieldses.org>
Cc: nfsv4@linux-nfs.org
Sent: Wednesday, November 15, 2006 10:37:16 AM
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!

A couple more things:

I notice there is a new client.c for 2.6.18.  Maybe the problem lies
there as code was ported from other places into that file?

My error only shows up with nfsv3,krb5 mounts.  My volumes also
have acls but I'm guessing that that is not causing any problems.

Thanks,
Paarvai


----- Original Message ----
From: Open Source <opensource3141@yahoo.com>
To: J. Bruce Fields <bfields@fieldses.org>
Cc: nfsv4@linux-nfs.org
Sent: Monday, November 13, 2006 2:16:11 PM
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!

Hi Bruce,

Regarding whether there is an error reply from the server, I
looked at the "MOUNT  V3 MNT Reply (Call In 46)" packet
(which is the last MOUNT packet in the dump summary I
sent previously).  This packet is going from the server
to the client.  When I look at it in the "Packet Details" (tree view)
under the "Mount Service" line, it says "Status: OK (0)"
so I guess there are no errors.

Yes, I did do an "exportfs -a" on the server after twiddling
the root_squash business.

Also, I am not trying to mount the same export in two places.
On the client I have mounted server:/export/home to /net/home
and then things fail when I try to mount server:/export/data to
/net/data.

Yes, I do think it is client side.  Things work when the client
is 2.6.17 and the server is 2.6.18 but not when the client is
2.6.18.

Is there some logging I can do on the client side to see what
might be happening?

Thanks,
Paarvai


----- Original Message ----
From: J. Bruce Fields <bfields@fieldses.org>
To: Open Source <opensource3141@yahoo.com>
Cc: nfsv4@linux-nfs.org
Sent: Monday, November 13, 2006 1:08:29 PM
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!

On Mon, Nov 13, 2006 at 12:31:20PM -0800, Open Source wrote:
> Here's a sanitized summary of my traffic.  I don't know how useful
> this might be, but if there is a specific line that might be helpful
> I can expand that and possibly send it to you.

OK, so none of those server replies are errors?  Then I guess it's the
client complaining.

Are you trying to mount the same export in two different places?  I
think some of the recent client changes may prevent that.

--b.





_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4





_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
