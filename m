From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Wed, 18 Mar 2009 12:31:08 -0400
Message-ID: <6B0D5E55-637D-4C99-B79D-57BB3D5B2E0B@oracle.com>
References: <49B57FB2.9020000@RedHat.com>
	<A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
	<49BFFDA6.8090500@RedHat.com>
	<C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>
	<49C0F20C.6030208@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49C0F20C.6030208@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 18, 2009, at Mar 18, 2009, 9:07 AM, Steve Dickson wrote:
> Chuck Lever wrote:
>> Hi Steve-
>>
>> On Mar 17, 2009, at Mar 17, 2009, 3:44 PM, Steve Dickson wrote:
>>> Sorry for the delayed response...
>>>
>>> Chuck Lever wrote:
>>>> Hi Steve-
>>>>
>>>> On Mar 9, 2009, at Mar 9, 2009, 4:44 PM, Steve Dickson wrote:
>>>>> Hello,
>>>>>
>>>>> The following patch set introduces a configuration file where
>>>>> mount options can be define. The options in the file can be
>>>>> applied globally or per server or per mount point.
>>>>>
>>>>> The patch set reuses the configuration parsing code that
>>>>> idmapd uses. I did added a couple enhancements like ignoring
>>>>> blanks in certain definitions as well as at the beginning of
>>>>> assignment statements.
>>>>>
>>>>> There are man pages include in the patch set but in a
>>>>> nut shell, the configuration file has three basic types
>>>>> of sections. A global section, server section and mount point
>>>>> section. There can only be one global section and multiple
>>>>> server and mount point sections.
>>>>>
>>>>> The mount command prioritize these sections in the following
>>>>> way:
>>>>>   * Options on the command line are always used.
>>>>>
>>>>>   * Options defined in the mount point section are used
>>>>>     as long a the options are not in the command line options.
>>>>>
>>>>>   * Options defined in the server section are used as long as
>>>>>     they are not defined on the command line or in the mount point
>>>>>     section.
>>>>>
>>>>>   * Options defined in the global section are used as long as the
>>>>>     options are not on the command line or in the mount point  
>>>>> section
>>>>>     or in the server section.
>>>>
>>>> This can become challenging to troubleshoot if there are these
>>>> semi-hidden options (cf. selinux).
>>> Why? 'mount -v' clearly shows what options are being used and then
>>> of course 'cat /proc/mounts' will show all the mount options.
>>
>> Because we expect certain default settings for these mount  
>> options.  If
>> they can be different on every system and every mount point, then you
>> have to remember to go back and check /etc/fstab, and your  
>> configuration
>> file, and so on.
> Yes... If you do change something... the default settings may or may  
> no longer
> be in effect... But I have faith that most admins would be able  
> realize
> this... If they change something... things are going to change! :-)

The point is that these settings are changed so infrequently (or are  
managed by a team of admins) that it will be too easy to overlook or  
forget this kind of change.  You are asking administrators to look in  
one more place when tracking down mount behavior, and I don't see a  
clear benefit for the added complexity.

It seems to me that automounter maps provide exactly this kind of  
functionality.  Why are they inadequate for this task?  If they are  
inadequate, why not improve automounter?

>>>> I don't get why the per-mount section is even needed --  
>>>> currently, the
>>>> mount options in /etc/fstab are used automatically if no options  
>>>> are
>>>> specified on the command line.
>>> Sure... this is option redundant with /etc/fstab but why not allow  
>>> people
>>> configure all the NFS mounts in one spot? Why make them edit  
>>> different
>>> files?
>>
>> Indeed... why make them edit /etc/fstab and some other config file?
> But the /etc/fstab file can't set global or per server options...

Yes, however you can change /etc/fstab with a global editor command.

>> We have /etc/fstab for static mounts and maps for automounter.  It's
>> already bad enough, and now we are considering another layer of
>> complexity.  Plus, the internal syntax of the mount command
>> configuration file is unlike either /etc/fstab or automounter maps.
> The format follows the already existing /etc/idmap.conf file. I
> basically reused the parsing routine that were already in nfs-utils.
> And I must admit, they were very well written...

Since we attempt to follow the example of other implementations  
(especially the reference implementation, Solaris) why are we not  
implementing a config file format that is used by other O/Ses?

I've looked for a similar facility on Solaris 10, and I don't find it  
mentioned in either mount(1M) or mount_nfs(1M).

> While its true the format does not follow either the /etc/fstab file
> or the autofs maps, I contend its a format that is much more
> straightforward... Basically uncomment things... and again I have
> faith in the admins that they will be able to quickly figure it out...
> What is really need is a GUI... but that's for another day... ;-)

Whether it is straightforward or not, it is a new and additional  
format that has to be understood.

It would make more sense if we were introducing this global config  
feature for _all_ file systems (via the mount command, not by the  
subcommands).  A GUI would follow the current trend of system-config-*  
and many other system utilities, such as NetworkManager.

>>>>> This is the first step toward moving the default NFS version  
>>>>> from 3
>>>>> to 4
>>>>> on the client.
>>>>
>>>> I would think that the _only_ step is to implement the version  
>>>> fallback
>>>> logic; ie. if the server doesn't support NFSv4, then use NFSv3,  
>>>> then
>>>> NFSv2.  Why can't an admin simply specify a fixed NFS version
>>>> (nfsvers=3) if there is a problem with NFSv4?
>>> They can... Nfsvers=3. When that is set, there will be no  
>>> negotiation.
>>
>> That's exactly my point.
>>
>> If an admin has a problem with using a particular version, they can
>> specify exactly what they want, today.
> Not globally... they have to change every single mount in both /etc/ 
> fstab
> and the autofs maps... verse making the change in one place.

If an admin cares enough to manage global changes, he will already use  
automounter and avoid /etc/fstab.

>> Adjusting the default version of a mount point is already possible  
>> today.
> Not really.... you can not change the default version you can only
> override it with each and every mount...

Again, this is not hard to do today.

>> People who don't care now probably are not likely to care if they  
>> get NFSv4,
>> as long as NFSv4 is working as well as NFSv3.
> This is an assumption I don't think we should make.

Why not?  The point of a default setting is that it works well in most  
cases.  If NFSv4 doesn't work well in most cases, then we have bigger  
problems.  Otherwise, people who care about the minor differences  
already have specific settings and configurations to deal with them.

>>>> It seems to me that if the admin hasn't specified nfsvers=, then  
>>>> she
>>>> does
>>>> not care which NFS version is used.
>>> True. And then the highest version the server supports
>>> will be negotiated. Having a Max/Min version will allow a the
>>> client to control that negotiation... Say the want v4 but not
>>> v4.1 ? Or may they only v41?
>>
>> If they care that much, why not just say nfsvers=4 and be done with  
>> it?
> v4 has had years more testing than v4.1.

You are suggesting that one cannot choose specifically among NFSv4  
minor versions with a mount option.  I truly truly hope this is not  
the case.

>>>>> Having a configuration file which allows users to define
>>>>> the maximum and minimum NFS versions that should be negotiated  
>>>>> is the
>>>>> right thing to do... IMHO.. Even though this patch does not does  
>>>>> not
>>>>> do that, it does lay the ground work for that type of  
>>>>> functionality
>>> Well I think most admins do want complete control over which NFS
>>> version will or will not be used... esp when it comes to v4 and v4.1
>>
>> I honestly don't see that.  Admins want the system to work, and not  
>> be
>> bothered with the trivial details.  They want either "give me  
>> anything
>> that works" or "give me this specific setting."  And we have the  
>> ability
>> to do that already.
> Yes... But for this part "give me this specific setting" having a  
> way to
> configure a setting, globally, per server, or per mount point is a
> good thing... imho...

No one has demonstrated yet that what we have today cannot provide the  
same effect as a global setting.  An automounter map provides this  
functionality.  What problem, exactly, are we trying to address here?

>> Even without a config file, Linux is open source.  If an admin cares
>> that much about exactly how the system works, she will build it  
>> herself,
>> and possibly modify the source code.
> Please... how many admins do you know that are also kernel  
> developers... :-)

You don't have to be a kernel developer, you just have to be able to  
read C and run "make".  That's been the whole argument for open source  
since the very beginning: it enables people to modify the code to make  
it do exactly what they want.

Admins I have known (and I myself was a large-scale Solaris admin, and  
before that, a VM/ESA admin, in previous lives) are not afraid to  
write and modify source code (when it's available), or create and  
deploy large infrastructures of their own code.  Everyone else can  
usually live pleasantly with exactly what they get in binary form.

Any admin worth his or her NaCl never relies on default settings.

>> I think the problem I have with this (besides the complexity) is  
>> that if
>> we must add more ways of avoiding NFSv4, then is NFSv4 really ready  
>> to
>> be made the default?
> Yes, I see your point... But I do think its not a bad thing to give  
> the
> admins the final say on how and what they want to run... because  
> they are
> the ones doing the front line support.. not us..
>
> I firmly believe if the transition to V4 is seamless and uneventful,
> having a configuration file will be non-issue... But if its not, then
> having a configuration file will be a good thing...

OK, then, what are we doing to make the transition seamless?  Do we  
know where the pain points are?  Do we have them documented (something  
that for example Fedora release notes can refer to)?  Are we giving  
our users real tools for managing the transition, like tools to  
convert ACLs?

Our defaults should be settings that work well out of the box in most  
environments.  If that isn't the case yet for NFSv4, then we shouldn't  
make it the default.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
