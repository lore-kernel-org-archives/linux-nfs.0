Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41095 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752210AbcKOQwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 11:52:53 -0500
Subject: Re: [PATCH/RFC nfs-utils] nfsdcltrack: read configuration from a file
To: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name>
 <1478692626.2394.9.camel@redhat.com>
 <877f8c9pku.fsf@notabene.neil.brown.name>
 <1478739358.2442.1.camel@redhat.com>
 <8737j0lyms.fsf@notabene.neil.brown.name>
 <1478790053.2402.5.camel@redhat.com>
 <87r36jkmi0.fsf@notabene.neil.brown.name>
 <1479040832.2387.10.camel@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <18ca987d-2db5-dfb4-aa31-a3a5a2d3e5d8@RedHat.com>
Date: Tue, 15 Nov 2016 11:52:52 -0500
MIME-Version: 1.0
In-Reply-To: <1479040832.2387.10.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/13/2016 07:40 AM, Jeff Layton wrote:
> On Fri, 2016-11-11 at 09:17 +1100, NeilBrown wrote:
>> On Fri, Nov 11 2016, Jeff Layton wrote:
>>
>>> On Thu, 2016-11-10 at 15:58 +1100, NeilBrown wrote:
>>>> As nfsdcltrack is normally run directly from the kernel
>>>> there is no opportunity to change the default
>>>> storage directory.  This can be useful in a cluster to
>>>> locate the "storage directory" on shared storage.
>>>>
>>>> The easiest alternative is to allow configuration to be read from a
>>>> file, particularly as nfs-utils already has code for parsing a config file.
>>>>
>>>> So read the config file "/etc/nfs.conf" (or as set by ./configure) and
>>>> look for "storagedir" and "debug" in the "nfsdcltrack" section.
>>>> These values can still be over-ridden by command line options.
>>>>
>>>> A generic name (nfs.conf) was changes for the config file so that
>>>> other daemons can be enhanced to read configuration from there.
>>>> This may be easier than passing command line arguments through systemd.
>>>>
>>> I like the basic idea, but I'm not so sure we want to use a generic
>>> config file like this. What else do you envision using this file?
>> See https://lwn.net/Articles/584373/ and surrounds (included where I
>> said that I wouldn't be providing patches:-).
Yeah the systemd folks have been asking for something like this for a while.

>>
>> I'm not happy with current mechanisms for passing configuration from a
>> configurator gui, through systemd, to various daemons.  Having a common
>> config file, rather having to stitch together command-line args, feels
>> like it might be a step in the right direction.  Given that I was adding
>> a config file, I thought that leaving it open-ended might be a good
>> idea.
I agree... A configuration file is better than command line arguments..
>>
>> We already have /etc/nfsmount.conf and /etc/idmapd.conf.
>> How many more do we want?
>> I note that that idmapd.conf contains Pipefs-Directory.  Various
>> other daemons need to know where that is.  Wouldn't it be nice if they
>> all read the one config file?
Yes. Having one file to configure both sides wold be nice. And having
a common way to change/edit that file would be good too... IMHO..
>>
>> I haven't resolved in my mind where the "impedance matching" should
>> happen.  To explain:
>> Different distros put their configuration in different places
>> (/etc/sysconfig/nfs /etc/defaults/nfs) and use different names for the
>> same value.  These files are all "name=val" files, without the [section]
>> headings of conf files.
>> What is the best way to get the config from there to the local variables
>> inside the various programs?
>>
>> Currently a systemd service runs a script which reads the configuration
>> file and writes out an environment file for systemd to read, which
>> provides command-line args for each daemon.  I'd rather something more
>> direct.
>>
>> If the parsing of /etc/nfs.conf allowed
>>   name=$var
>> to extract 'var' from the environment, then (almost) each distro
>> could have a static /etc/nfs.conf which listed which configuration
>> variables affected which settings.  Then systemd could read the
>> original configuration file to set up the environment, then each tool
>> would read /etc/nfs.conf to extract the desired parts of the environment.
+1

>>
>> Except that wouldn't work for nfsdcltrack as we cannot easily control
>> it's environment.  And there would probably be other things that didn't
>> quite work right.
> That could be remedied though it would take code changes in nfsdcltrack.
A lot of daemons would need this kind of updates.

>
>> Maybe the best thing is for the configurator-gui to be required to run
>> some post-processing thing which creates /etc/nfs.conf.
>> Then of course, it could just create systemd drop-in files which
>> created all the required arguments - then tells systemd to re-read those
>> files.  So maybe this is only useful for programs that aren't run via
>> systemd.
This first thing I thought of as well. Have GUI based configuration create the file
but i think the first step is have a static file for now...
>>
>> I'm as yet far from certain as to what I want, but keeping things
>> extensible seems like a generally good principle.
>>
> Agreed.
ditto
>
>>>
>>> That said, if we are going to do this, we should probably make it clear
>>> that it's for server-side configuration. Maybe "nfsd.conf" or
>>> "nfs-server.conf" would be a better name?
>> Why only server-side?  rpc-gssd needs configuration too.  It and
>> svcgssd (where used) are needed on both server and client (for
>> NFSv4.0).
>>
> I was thinking that we already had nfsmount.conf, so making this about
> server-side configuration would be more intuitive for users. You do have
> a good point about rpc.gssd though.
I think having a single configuration file for both side is the way we should go...

>
> Regardless, I do applaud the idea making the setup of NFS clients and
> servers less "fiddly". Once you get beyond a very basic setup,
> administering NFS as a service (client or server) is rather difficult
> today.
>
> Transitioning to a more unified configuration scheme seems like it would
> be good. Maybe we could even come up with a way to subsume nfsmount.conf
> as well?
>
Exactly... Or those files could be generated from the one configuration file...

A couple concerns:

- Precedence, will command argument still override what is in he configuration file?
  With nfsmount.conf the precedence is command line overrides config file which
  overrides the defaults

- Migration, how did we make it know that the variables in one file are no longer used
 or will be over written by another file?

- a common and safe way to edit the file?? 

steved.
