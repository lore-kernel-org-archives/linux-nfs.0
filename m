From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Tue, 17 Mar 2009 15:44:38 -0400
Message-ID: <49BFFDA6.8090500@RedHat.com>
References: <49B57FB2.9020000@RedHat.com> <A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbZCQTre (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 15:47:34 -0400
In-Reply-To: <A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response... 

Chuck Lever wrote:
> Hi Steve-
> 
> On Mar 9, 2009, at Mar 9, 2009, 4:44 PM, Steve Dickson wrote:
>> Hello,
>>
>> The following patch set introduces a configuration file where
>> mount options can be define. The options in the file can be
>> applied globally or per server or per mount point.
>>
>> The patch set reuses the configuration parsing code that
>> idmapd uses. I did added a couple enhancements like ignoring
>> blanks in certain definitions as well as at the beginning of
>> assignment statements.
>>
>> There are man pages include in the patch set but in a
>> nut shell, the configuration file has three basic types
>> of sections. A global section, server section and mount point
>> section. There can only be one global section and multiple
>> server and mount point sections.
>>
>> The mount command prioritize these sections in the following
>> way:
>>     * Options on the command line are always used.
>>
>>     * Options defined in the mount point section are used
>>       as long a the options are not in the command line options.
>>
>>     * Options defined in the server section are used as long as
>>       they are not defined on the command line or in the mount point
>>       section.
>>
>>     * Options defined in the global section are used as long as the
>>       options are not on the command line or in the mount point section
>>       or in the server section.
> 
> This can become challenging to troubleshoot if there are these
> semi-hidden options (cf. selinux).
Why? 'mount -v' clearly shows what options are being used and then 
of course 'cat /proc/mounts' will show all the mount options.

> 
> I don't get why the per-mount section is even needed -- currently, the
> mount options in /etc/fstab are used automatically if no options are
> specified on the command line.
Sure... this is option redundant with /etc/fstab but why not allow people
configure all the NFS mounts in one spot? Why make them edit different files?
Plus it was just really easy to do... 
 
> 
> Is there a specific use case you have in mind for the per-mount
> section?  
Not really... I figure would handy allow different options on
different file system to the same server...

> You just want a user to say "-o noac" and she will get all the
> remaining options in the per-mount section too?  
Yes.. the per-mount section will be added on to the command line options.

> I guess that means you also need to know when to specify the opposite to 
> turn off the options listed in this section (like using "-o ac" if noac 
> is contained in this section).  So again, that doesn't seem like especially 
> helpful behaviour in some cases.
Not sure I understand your point... but regardless setting 'ac=true' will 
cause the '-o ac' option to be added and 'ac=false' will cause the
'-o noac' option to be added... 
 
> 
> This scheme doesn't allow conditional options: "always use retrans=10 if
> proto=udp was specified, but retrans=2 if proto=tcp was specified."
True.. conditional options are not supported... until there is a demand
for them... 

> 
>> This is the first step toward moving the default NFS version from 3 to 4
>> on the client.
> 
> I would think that the _only_ step is to implement the version fallback
> logic; ie. if the server doesn't support NFSv4, then use NFSv3, then
> NFSv2.  Why can't an admin simply specify a fixed NFS version
> (nfsvers=3) if there is a problem with NFSv4?  
They can... Nfsvers=3. When that is set, there will be no negotiation  


> It seems to me that if the admin hasn't specified nfsvers=, then she does 
> not care which NFS version is used.
True. And then the highest version the server supports
will be negotiated. Having a Max/Min version will allow a the
client to control that negotiation... Say the want v4 but not
v4.1 ? Or may they only v41? 

> 
>> Having a configuration file which allows users to define
>> the maximum and minimum NFS versions that should be negotiated is the
>> right thing to do... IMHO.. Even though this patch does not does not
>> do that, it does lay the ground work for that type of functionality
Well I think most admins do want complete control over which NFS
version will or will not be used... esp when it comes to v4 and v4.1

thanks!

steved.
