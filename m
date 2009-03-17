From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Tue, 17 Mar 2009 16:17:05 -0400
Message-ID: <C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>
References: <49B57FB2.9020000@RedHat.com>
	<A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
	<49BFFDA6.8090500@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49BFFDA6.8090500@RedHat.com>
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

Hi Steve-

On Mar 17, 2009, at Mar 17, 2009, 3:44 PM, Steve Dickson wrote:
> Sorry for the delayed response...
>
> Chuck Lever wrote:
>> Hi Steve-
>>
>> On Mar 9, 2009, at Mar 9, 2009, 4:44 PM, Steve Dickson wrote:
>>> Hello,
>>>
>>> The following patch set introduces a configuration file where
>>> mount options can be define. The options in the file can be
>>> applied globally or per server or per mount point.
>>>
>>> The patch set reuses the configuration parsing code that
>>> idmapd uses. I did added a couple enhancements like ignoring
>>> blanks in certain definitions as well as at the beginning of
>>> assignment statements.
>>>
>>> There are man pages include in the patch set but in a
>>> nut shell, the configuration file has three basic types
>>> of sections. A global section, server section and mount point
>>> section. There can only be one global section and multiple
>>> server and mount point sections.
>>>
>>> The mount command prioritize these sections in the following
>>> way:
>>>    * Options on the command line are always used.
>>>
>>>    * Options defined in the mount point section are used
>>>      as long a the options are not in the command line options.
>>>
>>>    * Options defined in the server section are used as long as
>>>      they are not defined on the command line or in the mount point
>>>      section.
>>>
>>>    * Options defined in the global section are used as long as the
>>>      options are not on the command line or in the mount point  
>>> section
>>>      or in the server section.
>>
>> This can become challenging to troubleshoot if there are these
>> semi-hidden options (cf. selinux).
> Why? 'mount -v' clearly shows what options are being used and then
> of course 'cat /proc/mounts' will show all the mount options.

Because we expect certain default settings for these mount options.   
If they can be different on every system and every mount point, then  
you have to remember to go back and check /etc/fstab, and your  
configuration file, and so on.

>> I don't get why the per-mount section is even needed -- currently,  
>> the
>> mount options in /etc/fstab are used automatically if no options are
>> specified on the command line.
> Sure... this is option redundant with /etc/fstab but why not allow  
> people
> configure all the NFS mounts in one spot? Why make them edit  
> different files?

Indeed... why make them edit /etc/fstab and some other config file?   
We have /etc/fstab for static mounts and maps for automounter.  It's  
already bad enough, and now we are considering another layer of  
complexity.  Plus, the internal syntax of the mount command  
configuration file is unlike either /etc/fstab or automounter maps.

>> Is there a specific use case you have in mind for the per-mount
>> section?
> Not really... I figure would handy allow different options on
> different file system to the same server...
>
>> You just want a user to say "-o noac" and she will get all the
>> remaining options in the per-mount section too?
> Yes.. the per-mount section will be added on to the command line  
> options.
>
>> I guess that means you also need to know when to specify the  
>> opposite to
>> turn off the options listed in this section (like using "-o ac" if  
>> noac
>> is contained in this section).  So again, that doesn't seem like  
>> especially
>> helpful behavior in some cases.
> Not sure I understand your point... but regardless setting 'ac=true'  
> will
> cause the '-o ac' option to be added and 'ac=false' will cause the
> '-o noac' option to be added...

It's the same problem we have with "-o remount", except now the  
behavior is made even more inconsistent.  For example:

"mount -o remount sync"

on a noac mount silently strips the actimeo part of noac, and makes  
what was a "sync,actimeo=0" mount point just "sync".  Now we have a  
bunch of new little tricks to watch out for.

>>> This is the first step toward moving the default NFS version from  
>>> 3 to 4
>>> on the client.
>>
>> I would think that the _only_ step is to implement the version  
>> fallback
>> logic; ie. if the server doesn't support NFSv4, then use NFSv3, then
>> NFSv2.  Why can't an admin simply specify a fixed NFS version
>> (nfsvers=3) if there is a problem with NFSv4?
> They can... Nfsvers=3. When that is set, there will be no negotiation.

That's exactly my point.

If an admin has a problem with using a particular version, they can  
specify exactly what they want, today.  Adjusting the default version  
of a mount point is already possible today.  People who don't care now  
probably are not likely to care if they get NFSv4, as long as NFSv4 is  
working as well as NFSv3.

>> It seems to me that if the admin hasn't specified nfsvers=, then  
>> she does
>> not care which NFS version is used.
> True. And then the highest version the server supports
> will be negotiated. Having a Max/Min version will allow a the
> client to control that negotiation... Say the want v4 but not
> v4.1 ? Or may they only v41?

If they care that much, why not just say nfsvers=4 and be done with it?

>>> Having a configuration file which allows users to define
>>> the maximum and minimum NFS versions that should be negotiated is  
>>> the
>>> right thing to do... IMHO.. Even though this patch does not does not
>>> do that, it does lay the ground work for that type of functionality
> Well I think most admins do want complete control over which NFS
> version will or will not be used... esp when it comes to v4 and v4.1

I honestly don't see that.  Admins want the system to work, and not be  
bothered with the trivial details.  They want either "give me anything  
that works" or "give me this specific setting."  And we have the  
ability to do that already.

Even without a config file, Linux is open source.  If an admin cares  
that much about exactly how the system works, she will build it  
herself, and possibly modify the source code.

I think the problem I have with this (besides the complexity) is that  
if we must add more ways of avoiding NFSv4, then is NFSv4 really ready  
to be made the default?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
