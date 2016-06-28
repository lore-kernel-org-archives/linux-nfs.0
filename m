Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40906 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbcF1Uiw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2016 16:38:52 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are enabled
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ecc17a51-f207-bb5a-9802-5e8e84337293@RedHat.com>
Date: Tue, 28 Jun 2016 16:38:44 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <468F1196-CEBE-45E3-8F71-DA3844ED12FF@oracle.com>
References: <1466520807-4340-1-git-send-email-steved@redhat.com> <09ECB137-8EC4-4713-B5F4-44D0405B2700@oracle.com> <c21d7a5d-853f-1722-53b4-99f66f263d74@RedHat.com> <AA20A3F4-82FB-4118-B0F2-012890D24042@oracle.com> <a82a0e31-a0e0-409a-8310-bd62cf0436b5@RedHat.com> <1D39CEF6-AC29-4166-95DF-ADBD2C0286B3@oracle.com> <e3735233-446f-ff18-6127-41ed956e6f91@RedHat.com> <73CFA6F9-C983-47D7-972C-9DF782731F3C@oracle.com> <2085406d-1e41-46b2-6791-2a3208f5497b@RedHat.com> <DE6D6AB1-4C56-43B2-8E11-778A29CF472C@oracle.com> <ecc17a51-f207-bb5a-9802-5e8e84337293@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 28, 2016, at 2:11 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> 
> 
>> On 06/28/2016 12:27 PM, Chuck Lever wrote:
>> 
>>> On Jun 28, 2016, at 10:27 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> Again, sorry for the delay... That darn flux capacitor broke... again!!! :-)
>>> 
>>>> On 06/23/2016 09:30 PM, Chuck Lever wrote:
>>>> 
>>>>> On Jun 23, 2016, at 11:57 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>> [snip]
>>> 
>>>>> the key tab does have a nfs/hosname@REALM entry. So the 
>>>>> call to the KDC is probably failing... which 
>>>>> could be construed as a misconfiguration, but
>>>>> that misconfiguration should not even come into 
>>>>> play with sec=sys mounts... IMHO...
>>>> 
>>>> I disagree, of course. sec=sys means the client is not going
>>>> to use Kerberos to authenticate individual user requests,
>>>> and users don't need a Kerberos ticket to access their files.
>>>> That's still the case.
>>>> 
>>>> I'm not aware of any promise that sec=sys means there is
>>>> no Kerberos within 50 miles of that mount.
>>> I think that's is the assumption... No Kerberos will be
>>> needed for sec=sys mounts. Its not when Kerberos is 
>>> not configured.
>> 
>> NFSv3 sec=sys happens to mean that no Kerberos is needed.
>> This hasn't changed either.
>> 
>> NFSv4 sec=sys is different. Just like NFSv4 ACLs, and
>> NFSv4 ID mapping, and NFSv4 locking, and so on.
>> 
>> Note though that Kerberos isn't needed for NFSv4 sec=sys
>> even when there is a keytab. The client negotiates and
>> operates without it.
> If there is a keytab... there will be rpc.gssd runnning
> which will cause an upcall... and the negotiation starts
> with krb5i.. So yes its not needed but it will be tried.
> 
>> 
>> 
>>>> If there are valid keytabs on both systems, they need to
>>>> be set up correctly. If there's a misconfiguration, then
>>>> gssd needs to report it precisely instead of time out.
>>>> And it's just as easy to add a service principal to a keytab
>>>> as it is to disable a systemd service in that case.
>>> I think its more straightforward to disable a service
>>> that is not needed than to have to add a principal to a 
>>> keytab for a service that's not being used or needed.
>> 
>> IMO automating NFS setup so that it chooses the most
>> secure possible settings without intervention is the
>> best possible solution.
> Sure... now back to the point. ;-) 
> 
> 
>>>> 
>>>> The problem is not fixed by disabling gssd, it's just
>>>> hidden in some cases.
>>> I agree this %100... All I'm saying there should be a 
>>> way to disable it when the daemon is not needed or used.
>> 
>> NFSv4 sec=sys *does* use Kerberos, when it is available.
>> It has for years.
> Right... lets define "available" when rpc.gssd is running.
> When rpc.gssd is not running Kerberos is not available.

OK, but now whenever a change to the Kerberos
configuration on the host is made (the keytab is
created or destroyed, or a principal is added or
removed from the keytab), an extra step is needed
to ensure secure NFS is working properly.

Should we go farther and say that, if there happen
to be no sec=krb5[ip] mounts on the system, gssd
should be shut down? I mean, it's not being used,
so let's turn it off!

There is a host/ principal in the keytab. That means
Kerberos is active on that system, and gssd can use it.
That means it is possible that an administrator (or
automounter) may specify sec=krb5 at some point
during the life of this client. For me that means gssd
should be running on this system.

Another way to achieve your goal is to add a command
line option to gssd which specifies which principal in the
local keytab to use as the machine credential. Specify
a principal that is not in the keytab, and gssd should do
no negotiation at all, and will return immediately.

There may already be a command line option to do this
(I'm not at liberty to confirm my memory at the moment).

That would be an immediate solution for this customer,
if provisioning an nfs/ service principal on their server
is still anathema, and no other code change is needed.


>> Documentation should be updated to state that if Kerberos
>> is configured on clients, they will attempt to use it to
>> manage some operations that are common to all NFSv4 mount
>> points on that client, even when a mount point uses sec=sys.
>> 
>> Kerberos will be used for user authentication only if the
>> client administrator has not specified a sec= setting, but
>> the server export allows the use of Kerberos; or if the
>> client administrator has specified a sec=krb5, sec=krb5i,
>> or sec=krb5p setting.
>> 
>> The reason for using Kerberos for common operations is
>> that a client may have just one lease management principal.
>> If the client uses sec=sys and sec=krb5 mounts, and the
>> sec=sys mount is done first, then lease management would use
>> sys as well. The client cannot change this principal after
>> it has established a lease and files are open.
>> 
>> A subsequent sec=krb5 mount will also use sec=sys for
>> lease management. This will be surprising and insecure
>> behavior. Therefore, all mounts from this client attempt
>> to set up a krb5 lease management transport.
>> 
>> The server should have an nfs/ service principal. It
>> doesn't _require_ one, but it's a best practice to have
>> one in place.
> Yeah our documentation is lacking in this area...
> 
>> 
>> Administrators that have Kerberos available should use
>> it. There's no overhead to enabling it on NFS servers,
>> as long as the list of security flavors the server
>> returns for each export does not include Kerberos
>> flavors.
> Admins are going to do what they want to no matter
> what we say... IMHO... 
> 
>> 
>> 
>>> Having it automatically started just because there is a 
>>> keytab, at first, I thought was a good idea, now
>>> it turns not people really don't what miscellaneous 
>>> daemons running. Case in point gssproxy... Automatically
>>> comes but there is a way to disable it. With rpc.gssd
>>> there is not (easily).
>> 
>> There are good reasons to disable daemons:
>> 
>> - The daemon consumes a lot of resources.
>> - The daemon exposes an attack surface.
>> 
>> gssd does neither.
> How about not needed? no rpc.gssd.. no upcall... no problem... ;-)

>> There are good reasons not to disable daemons:
> I'm assuming you meant "to disable" or "not to enable" here.

No, I meant exactly what I wrote. Let's rewrite it
"good reasons to leave a daemon enabled"


>> - It enables simpler administration.
>> - It keeps the test matrix narrow (because you
>>   have to test just one configuration, not
>>   multiple ones: gssd enabled, gssd disabled,
>>   and so on).
>> 
>> Always enabling gssd provides both of these benefits.
> This is a production environment so there is no testing

I meant QA testing by the distributor. Without the extra
knob, the QA tester has to test only the configuration
where gssd is enabled.

Whenever you add a knob like this, you have to double
your QA test matrix.


> but simpler admin is never a bad thing.
> 
>> 
>> 
>>>>> This patch just tweaking that method to make things easier.
>>>> 
>>>> It makes one thing easier, and other things more difficult.
>>>> As a community, I thought our goal was to make Kerberos
>>>> easier to use, not easier to turn off.
>>> Again I can't agree with you more! But this is the case 
>>> were Kerberos is *not* being used for NFS... we should
>>> make that case work as well...
>> 
>> Agreed.
>> 
>> But NFSv4 sec=sys *does* use Kerberos when Kerberos is
>> configured on the system. It's a fact, and we now need to
>> make it convenient and natural and bug-free. The choice is
>> between increasing security and just making it work, or
>> adding one more knob that administrators have to Google for.
> If they do not want use Kerberos for NFS, whether is a good
> idea or not, we can not force them to... Or can we?

No-one is forcing anyone to do anything.


>>>>> To address your concern about covering up a bug. I just don't
>>>>> see it... The code is doing exactly what its asked to do.
>>>>> By default the kernel asks krb5i context (when rpc.gssd
>>>>> is run). rpc.gssd looking for a principle in the key tab, 
>>>>> when found the KDC is called... 
>>>>> 
>>>>> Everything is working just like it should and it is
>>>>> failing just like it should. I'm just trying to 
>>>>> eliminate all this process when not needed, in 
>>>>> an easier way..
>>>> 
>>>> I'm not even sure now what the use case is. The client has
>>>> proper principals, but the server doesn't? The server
>>>> should refuse the init sec context immediately. Is gssd
>>>> even running on the server?
>>> No they don't because they are not using Kerberos for NFS...
>> 
>> OK, let's state clearly what's going on here:
>> 
>> 
>> The client has a host/ principal. gssd is started
>> automatically.
>> 
>> 
>> The server has what?
> No info on the server other than its Linux and the 
> nfs server is running.
> 
>> 
>> If the server has a keytab and an nfs/ principal,
>> gss-proxy should be running, and there are no delays.
> In my testing when gss-proxy is not runnning the mount
> hangs.
> 
>> 
>> If the server has a keytab and no nfs/ principal,
>> gss-proxy should be running, and any init sec
>> context should fail immediately. There should be no
>> delay. (If there is a delay, that needs to be
>> troubleshot).
>> 
>> If the server does not have a keytab, gss-proxy will
>> not be running, and NFSv4 clients will have to sense
>> this. It takes a moment for each sniff. Otherwise,
>> there's no operational difference.
>> 
>> 
>> I'm assuming then that the problem is that Kerberos
>> is not set up on the _server_. Can you confirm this?
> I'll try... but we should have to force people to 
> set up Kerberos on server they are not going to use.

I say one more time: no-one is forcing anyone to
do anything.


>> Also, this negotiation should be done only during
>> the first contact of each server after a client
>> reboot, thus the delay happens only during the first
>> mount, not during subsequent ones. Can that also be
>> confirmed?
> It appears it happen on all of them. 

Can this customer's observed behavior be reproduced
in vitro? Seems like there are many unknowns here, and
it would make sense to get more answers before
proposing a long-term change to our administrative
interfaces.


>>> So I guess this is what we are saying:
>>> 
>>> If you what to used Kerberos for anything at all,
>>> they must configure it for NFS for their clients
>>> to work properly... I'm not sure we really want to
>>> say this.
>> 
>> Well, the clients are working properly without the
>> server principal in place. They just have an extra
>> delay at mount time. (you yourself pointed out in
>> an earlier e-mail that the client is doing everything
>> correctly, and no mention has been made of any other
>> operational issue).
> This appeared to be the case.
> 
>> 
>> We should encourage customers to set up in the most
>> secure way possible. In this case:
>> 
>> - Kerberos is already available in the environment
>> 
>> - It's not _required_ only _recommended_ (clients can
>>   still use sec=sys without it) for the server to
>>   enable Kerberos, but it's a best practice
>> 
>> I'm guessing that if gssd and gss-proxy are running on
>> the server all the time, even when there is no keytab,
>> that delay should go away for everyone. So:
>> 
>> - Always run a gssd service on servers that export NFSv4
>>   (I assume this will address the delay problem)
>> 
>> - Recommend the NFS server be provisioned with an nfs/
>>   principal, and explicitly specify sec=sys on exports
>>   to prevent clients from negotiating an unwanted Kerberos
>>   security setting
> Or don't start rpc.gssd... ;-)
> 
>> 
>> I far prefer these fixes to adding another administrative
>> setting on the client. It encourages better security, and
>> it addresses the problem for all NFS clients that might
>> want to try using Kerberos against Linux NFS servers, for
>> whatever reason.
> As you say we can only recommend... If they don't 
> now want to use secure mounts in a Kerberos environment
> we should not make them, is all I'm saying. 

I don't see that I'm proposing otherwise. I've simply
described the recommended best practice.

NFSv4 sec=sys works fine with or without Kerberos
present.

However, if there is a KDC available, and the client
is provisioned with a host/ principal, we recommend
adding an nfs/ service principal to the NFS server.
sec=sys still works in the absence of said principal.

How is that forcing anything?

In the specific case for your customer, it's simply not
clear why the delays occur. More information is needed
before it makes sense to propose a code change.


>>>> Suppose there are a thousand clients and one broken
>>>> server. An administrator would fix that one server by
>>>> adding an extra service principal, rather than log
>>>> into a thousand clients to change a setting on each.
>>>> 
>>>> Suppose your client wants both sys and krb5 mounts of
>>>> a group of servers, and some are "misconfigured."
>>>> You have to enable gssd on the client but there are still
>>>> delays on the sec=sys mounts.
>>> In both these cases you are assuming Kerberos mounts 
>>> are being used and so Kerberos should be configured 
>>> for NFS. That is just not the case.
>> 
>> My assumption is that administrators would prefer automatic
>> client set up, and good security by default.
> I don't think we can make any assumption what admins want.
> They want strong security, but not with NFS... That's
> their choice, not ours.

>> There's no way to know in advance whether an administrator
>> will want sec=sys and sec=krb5 mounts on the same system.
>> /etc/fstab can be changed at any time, mounts can be done
>> by hand, or the administrator can add or remove principals
>> from /etc/krb5.keytab.
>> 
>> Our clients have to work when there are just sec=sys
>> mounts, or when there are sec=sys and sec=krb5 mounts.
>> They must allow on-demand configuration of sec=krb5. They
>> must attempt to provide the best possible level of security
>> at all times.
>> 
>> The out-of-the-shrinkwrap configuration must assume a mix
>> of capabilities.
> I agree... And they are... But if they know for a fact, that 
> their client(s) will never want to use secure mount, which 
> I'm sure there a few out there, I see no problem in 
> not starting a service they well never use.

Why "force" an admin to worry about whether some
random service is running or not?

IMO the mechanism (one or more daemons, a systemctl
service, the use of a keyring, or using The Force) should
be transparent to the administrator, who should care only
about security policy settings.

The whole idea of having separate services for enabling
NFS security is confusing IMO. The default is sec=sys,
but as soon as you vary from that, things get wonky.

It also makes it much harder for distributors or upstream
developers to make alterations to this mechanism while
not altering the administrative interfaces.

I have to check whether "SECURE=YES" is uncommented
in /etc/sysconfig/nfs. I have to check whether nfs.target
includes nfs-secure.service. None of this is obvious or
desirable, and after all is said and done I usually miss
something and have to Google anyway, before a valid
krb5.conf and adding "sec=krb5" works properly.

And the only reason we have this complication is because
someone complained once about extra daemons running.
It's just superstition.

Why can't it be simple for all sec= settings?


>>>> In fact, I think that's going to be pretty common. Why add
>>>> an NFS service principal on a client if you don't expect
>>>> to use sec=krb5 some of the time?
>>> In that case adding the principal does make sense. But...
>>> 
>>> Why *must* you add a principal when you know only sec=sys 
>>> mounts will be used?
>> 
>> Explained in detail above (and this is only for NFSv4, and
>> is not at all a _must_). But in summary:
>> 
>> A client will attempt to use Kerberos for NFSv4 sec=sys when
>> there is a host/ or nfs/ principal in its keytab. That needs
>> to be documented.
>> 
>> Our _recommendation_ is that the server be provisioned with
>> an nfs/ principal as well when NFSv4 is used in an environment
>> where Kerberos is present. This eliminates a costly per-mount
>> security negotiation, and enables cryptographically strong
>> authentication of each client that mounts that server. NFSv4
>> sec=sys works properly otherwise without this principal.
> The was beautifully said... and I agree with all... 
> But customer is going to turn around and tell me to go pound
> sand... Because they are not about to touching their server!!! :-)

What if this customer came back and said "We also
want this to work with NFSv2 on UDP?" Would you
still want to accommodate them?

If they don't want to provision an nfs/ service principal
it would be really helpful for us to know why. IMO the
community should not accommodate anyone who
refuses to use a best practice without a reason. Is
there a reason?


> Esp when all they have to do is disable a service on the client
> where the hang is occurring. 

They could also use NFSv3.
