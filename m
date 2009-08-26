From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Wed, 26 Aug 2009 08:10:02 -0400
Message-ID: <4A95261A.5080601@RedHat.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
	<CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
	<4A943914.9020104@RedHat.com>
	<7AB7BC01-F9E5-4611-BB4B-2B6E27069631@oracle.com>
	<4A944645.1020003@RedHat.com>
	<29B9DDA7-00A2-4EDE-93B4-D00D5427CD70@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <29B9DDA7-00A2-4EDE-93B4-D00D5427CD70@oracle.com>
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

On 08/25/2009 04:37 PM, Chuck Lever wrote:
>>>> Also note there is no '-o ' flag to umount so 'umount -t nfs -o v4' is
>>>> not valid... but 'umount -t nfs' is and works on both nfs4 and nfs
>>>> file systems.
>>>
>>> Sorry I wasn't clear.  I meant that umount.nfs should be able to read a
>>> line in /etc/mtab that has "nfs" and "v4" and do the right thing... then
>>> you wouldn't have to change the fs_type in /etc/mtab at all.
>> Ok.. I gotta you now... and I did take a few minutes to look into what
>> something like this would take... I quickly came to the realization
>> that adding all complexity to make a system file, that nobody see or
>> care about, more aesthetic really not worth it and not necessary,
>> IMHO....
> 
> It's more of a maintainability issue.  Make umount.nfs behave the same
> way for v2, v3, and v4, instead of doing one thing for v2/v3 and another
> for v4.
Then why even have a mount.nfs4 command? Lets simple get ride of that 
command all together and ignore the fact nfs and nfs4 are to separate 
filesystems? Personally I think this would be wrong... 

It was deemed, rightly so, that nfs4 would be a separate file system.
So there there will be things that will have to be done to maintain
both of them... All this patch set does is create a shorthand way of 
mounting an nfs4 file system... nothing more and nothing less... 
   
> 
>> Point being,  umount is so simple when it comes to umounting a nfs4 file
>> system... It basically does nothing! Which is a beautiful thing! So to
>> added
>> all the code (on both the mount and umount side) to translate
>> '-t nfs -o v4' into nfs4 (which  would have to happen since
>> del_mtab() takes a fs type) is just not worth it... Especially when
>> the other option is adding no code to the umount side...
> 
> I doubt it would be a lot of complexity, actually.  We already have
> parser calls in umount.nfs to handle v2/v3 version/transport
> negotiation, so I don't think it would be much of a stretch at all to
> look for "v4" before deciding whether to do a v2/v3 umount or a v4 umount.

Let's make a deal! ;-) If a bug report is opened about the exact user-given command 
arguments to the mount command are not portrayed correctly in /etc/mtab, 
I will fix that bug and then buy you dinner! :-) 

steved.
