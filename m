From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS Client mounts hang when exported directory do not
 exist
Date: Fri, 11 Apr 2008 12:37:23 -0400
Message-ID: <47FF93C3.8040109@RedHat.com>
References: <47FF7FCC.2050403@RedHat.com> <47FF902C.40301@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: chuck.lever@oracle.com
Return-path: <fedora-kernel-list-bounces@redhat.com>
In-Reply-To: <47FF902C.40301@oracle.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-kernel-list>
List-Post: <mailto:fedora-kernel-list@redhat.com>
List-Help: <mailto:fedora-kernel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=subscribe>
Sender: fedora-kernel-list-bounces@redhat.com
Errors-To: fedora-kernel-list-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Steve Dickson wrote:
>> This patch fixes a regression that was introduced by the string based
>> mounts.
>> nfs_mount() statically returns -EACCES for every error returned
>> by the remote mounted. This is incorrect because -EACCES is
>> an non-fatal error to the mount.nfs command. This error causes
>> mount.nfs to retry the mount even in the case when the exported
>> directory does not exist. 
> 
> I don't doubt this is the case, but I'd like to see a few real world
> examples (maybe even add them as documentary comments in mount.nfs or in
> the kernel).
Thats easy.. Do a Fedora install over NFS and mistype the mount
point. Instead of returning immediately like it should, one has to
wait 2mins for the error.. 

ENOENT during a mount has always been a fatal error as it should be
and this patch is just restoring that fact.

steved.
