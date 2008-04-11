From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] NFS Client mounts hang when exported directory do not
	exist
Date: Fri, 11 Apr 2008 11:20:10 -0400
Message-ID: <1207927210.3379.1.camel@localhost.localdomain>
References: <47FF7FCC.2050403@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <fedora-kernel-list-bounces@redhat.com>
In-Reply-To: <47FF7FCC.2050403-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
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

On Fri, 2008-04-11 at 11:12 -0400, Steve Dickson wrote:
> This patch fixes a regression that was introduced by the string based mounts. 
> 
> nfs_mount() statically returns -EACCES for every error returned
> by the remote mounted. This is incorrect because -EACCES is
> an non-fatal error to the mount.nfs command. This error causes
> mount.nfs to retry the mount even in the case when the exported
> directory does not exist. 
> 
> This patch maps the errors returned by the remote mountd into
> valid errno values, exactly how it was done pre-string based 
> mounts. By returning the correct errno enables mount.nfs 
> to do the right thing.

Does this mean the EACCES can/will again become fatal in mount.nfs like
it used to be?

https://bugzilla.redhat.com/show_bug.cgi?id=439807

-Eric
