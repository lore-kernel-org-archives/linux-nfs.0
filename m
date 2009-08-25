From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Tue, 25 Aug 2009 15:18:44 -0400
Message-ID: <4A943914.9020104@RedHat.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
	<CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/25/2009 02:59 PM, Chuck Lever wrote:
> On Aug 25, 2009, at 1:55 PM, Steve Dickson wrote:
>> commit 1471d23d692efc7388794a8a3c3b9e548d1c5be8
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Tue Aug 25 12:15:18 2009 -0400
>>
>>    Make sure umount use correct fs type.
>>
>>    umounts use the fs type in /etc/mtab to determine
>>    which file system is being unmounted. The mtab
>>    entry is create during the mount. To ensure the
>>    correct entry is create when the fs type changes
>>    due to the mount options, the address of the fs_type
>>    variable has to be passed so it can be updated.
> 
> In general, my policy is to record the user requested mount options in
> /etc/mtab, and let umount.nfs handle renegotiating as needed.  For
> version/transport this means that the server's configuration can change
> between the mount and the umount, and the umount will still work.
> 
> Perhaps this is not a consideration for NFSv4, but leaving the mount
> options as specified by the user would save the need to update the fs
> type, and would be a consistent policy for v2, v3, and v4.  I think it
> would be cleaner to teach umount.nfs to do the right thing with "-t nfs
> -o v4" rather than rewriting the options in /etc/mtab.
Since nfs4 is truly a separate/different file system from nfs in the
kernel, I think we should continue making that distinction in system 
files like mtab and /proc/mounts.... 

Also note there is no '-o ' flag to umount so 'umount -t nfs -o v4' is
not valid... but 'umount -t nfs' is and works on both nfs4 and nfs
file systems. 
 
steved.
